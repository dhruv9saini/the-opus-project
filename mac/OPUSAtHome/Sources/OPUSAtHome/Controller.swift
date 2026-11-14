import Foundation
import AppKit
import ServiceManagement
import OPUSAtHomeCore

@MainActor
final class Controller: ObservableObject {
    static let shared = Controller()
    let store = DataStore()
    private(set) var tools = ToolEnvironment()

    @Published var settings: AppSettings {
        didSet {
            guard settings != oldValue else { return }
            store.save(settings)
            if settings.agent != oldValue.agent || settings.openPullRequests != oldValue.openPullRequests {
                usage = nil
                usageCheckedAt = nil
                refreshPrerequisites()
            }
            if !settings.enabled, running, !manualRun { stopRun() }
            evaluate()
        }
    }
    @Published var status = "Off"
    @Published var running = false
    @Published var runStatus = ""
    @Published var runStarted: Date?
    @Published var usage: Usage?
    @Published var usageError: String?
    @Published var prerequisites: [Prerequisite] = []
    @Published var history: [ContributionRecord] = []
    @Published var launchAtLogin = SMAppService.mainApp.status == .enabled

    private var usageCheckedAt: Date?
    private var backoffUntil: Date?
    private let stopFlag = StopFlag()
    private var checkingUsage = false
    private var manualRun = false
    private var timer: Timer?
    private let sleepAssertion = SleepAssertion()
    private var checkingPrereqs = false

    init() {
        settings = store.loadSettings()
        history = store.loadHistory()
        refreshPrerequisites()
        Power.observeChanges { [weak self] in
            Task { @MainActor in self?.powerChanged() }
        }
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.evaluate() }
        }
        evaluate()
    }

    var missingRequired: [Prerequisite] { prerequisites.filter { $0.required && !$0.ok } }

    var menuBarSymbol: String {
        if running { return "music.quarternote.3" }
        return settings.enabled ? "music.note" : "music.note.list"
    }

    func refreshPrerequisites() {
        guard !checkingPrereqs else { return }
        checkingPrereqs = true
        let s = settings
        Task.detached {
            let tools = ToolEnvironment()
            let list = Prerequisites.check(s, tools: tools)
            await MainActor.run {
                self.tools = tools
                self.prerequisites = list
                self.checkingPrereqs = false
                self.evaluate()
            }
        }
    }

    func powerChanged() {
        if running, !manualRun, settings.requireCharging, !Power.onCharger() {
            runStatus = "Unplugged; stopping"
            stopRun()
        }
        evaluate()
    }

    func evaluate() {
        if running {
            status = "Running: \(runStatus)"
            if !checkingUsage, usageCheckedAt == nil || Date().timeIntervalSince(usageCheckedAt!) > 300 {
                refreshUsage()
            }
            return
        }
        if !settings.enabled {
            status = "Off"
            return
        }
        if prerequisites.isEmpty {
            status = "Checking setup..."
            return
        }
        if let first = missingRequired.first {
            status = "Setup needed: \(first.name)"
            return
        }
        let conditions = Conditions(onCharger: Power.onCharger(), idleSeconds: Power.idleSeconds(), usage: usage, backoffUntil: backoffUntil)
        if let gate = Policy.gates(settings, conditions) {
            status = gate.reason
            return
        }
        if usageCheckedAt == nil || Date().timeIntervalSince(usageCheckedAt!) > 600 {
            refreshUsage(thenEvaluate: true)
            status = "Checking \(settings.agent.displayName) usage..."
            return
        }
        if checkingUsage {
            status = "Checking \(settings.agent.displayName) usage..."
            return
        }
        let d = Policy.quota(settings, usage, now: Date())
        status = d.reason
        if d.run { startRun(manual: false) }
    }

    func refreshUsage(thenEvaluate: Bool = false) {
        usageCheckedAt = Date()
        checkingUsage = true
        let agent = settings.agent
        let tools = self.tools
        Task.detached {
            let (u, err) = UsageReader.read(agent, tools: tools)
            await MainActor.run {
                self.usage = u
                self.usageError = err
                self.checkingUsage = false
                if self.running, let reason = Policy.stopReason(self.settings, u) {
                    self.runStatus = "\(reason); stopping"
                    self.status = "Running: \(self.runStatus)"
                    self.stopRun()
                }
                if thenEvaluate && !self.running { self.evaluate() }
            }
        }
    }

    func runNow() {
        guard !running else { return }
        startRun(manual: true)
    }

    func stopRun() {
        stopFlag.set(true)
    }

    private func startRun(manual: Bool) {
        guard !running else { return }
        running = true
        manualRun = manual
        stopFlag.set(false)
        usageCheckedAt = Date()
        runStarted = Date()
        runStatus = "Starting"
        status = "Running: Starting"
        sleepAssertion.hold("OPUS@Home is transcribing a score")
        let runner = ContributionRunner(store: store, tools: tools, settings: settings,
                                        options: RunOptions(openPullRequest: settings.openPullRequests, maxMinutes: settings.maxRunMinutes))
        runner.onStatus = { [weak self] s in
            Task { @MainActor in
                self?.runStatus = s
                if self?.running == true { self?.status = "Running: \(s)" }
            }
        }
        let flag = stopFlag
        Task.detached { [weak self] in
            let record = runner.run(shouldStop: { flag.get() })
            await MainActor.run { self?.finishRun(record) }
        }
    }

    private func finishRun(_ record: ContributionRecord) {
        running = false
        manualRun = false
        runStarted = nil
        sleepAssertion.release()
        store.append(record)
        history = store.loadHistory()
        if record.pullRequestURL != nil {
            backoffUntil = nil
        } else if record.outcome == "Stopped" {
            backoffUntil = nil
        } else if record.outcome.hasPrefix("No contribution") {
            backoffUntil = Date().addingTimeInterval(2 * 3600)
        } else {
            backoffUntil = Date().addingTimeInterval(30 * 60)
        }
        usage = nil
        usageCheckedAt = nil
        evaluate()
    }

    func setLaunchAtLogin(_ on: Bool) {
        do {
            if on { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
        } catch {
            NSLog("OPUS@Home login item: \(error)")
        }
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }

    func openLatestLog() {
        let latest = (try? FileManager.default.contentsOfDirectory(at: store.logsURL, includingPropertiesForKeys: nil))?
            .filter { $0.pathExtension == "log" }.sorted { $0.lastPathComponent > $1.lastPathComponent }.first
        NSWorkspace.shared.open(latest ?? store.logsURL)
    }
}

final class StopFlag: @unchecked Sendable {
    private let lock = NSLock()
    private var value = false
    func set(_ v: Bool) { lock.lock(); value = v; lock.unlock() }
    func get() -> Bool { lock.lock(); defer { lock.unlock() }; return value }
}
