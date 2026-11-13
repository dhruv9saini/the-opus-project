import SwiftUI
import AppKit
import OPUSHelperCore

@main
enum Entry {
    static func main() {
        let args = Array(CommandLine.arguments.dropFirst())
        if let code = CLI.handle(args) { exit(code) }
        OPUSHelperApp.main()
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var previewWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard ProcessInfo.processInfo.environment["OPUS_HELPER_PREVIEW"] == "1" else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let w = NSWindow(contentRect: NSRect(x: 80, y: 200, width: 340, height: 420),
                             styleMask: [.titled], backing: .buffered, defer: false)
            w.title = "Menu preview"
            w.contentView = NSHostingView(rootView: MenuContent().environmentObject(Controller.shared))
            w.makeKeyAndOrderFront(nil)
            self.previewWindow = w
            SettingsWindow.show()
        }
    }
}

struct OPUSHelperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @StateObject private var controller = Controller.shared

    var body: some Scene {
        MenuBarExtra {
            MenuContent().environmentObject(controller)
        } label: {
            Image(systemName: controller.menuBarSymbol)
        }
        .menuBarExtraStyle(.window)

        Settings {
            EmptyView()
        }
    }
}

struct MenuContent: View {
    @EnvironmentObject var c: Controller
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("OPUS Helper").font(.headline)
                Spacer()
                Toggle("", isOn: $c.settings.enabled).toggleStyle(.switch).labelsHidden()
            }
            Text(c.status).font(.callout).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)

            if let u = c.usage {
                Label("\(c.settings.agent.displayName): \(u.summary())", systemImage: "gauge.with.dots.needle.33percent")
                    .font(.caption).foregroundStyle(.secondary)
            } else if let e = c.usageError, c.settings.enabled {
                Label(e, systemImage: "exclamationmark.triangle").font(.caption).foregroundStyle(.secondary)
            }

            if !c.missingRequired.isEmpty {
                Divider()
                Text("Setup needed").font(.subheadline.bold())
                ForEach(c.missingRequired) { p in
                    HStack {
                        Text("\(p.name): \(p.detail)").font(.caption)
                        Spacer()
                        if let fix = p.fix {
                            Button("Copy command") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(fix, forType: .string)
                            }.controlSize(.small)
                        }
                    }
                }
                Button("Check again") { c.refreshPrerequisites() }.controlSize(.small)
            }

            Divider()
            HStack {
                if c.running {
                    Button("Stop this run") { c.stopRun() }
                } else {
                    Button("Run one now") { c.runNow() }.disabled(!c.missingRequired.isEmpty)
                }
                Spacer()
                Button("Log") { c.openLatestLog() }
            }

            if !c.history.isEmpty {
                Divider()
                Text("Recent runs").font(.subheadline.bold())
                ForEach(c.history.prefix(5)) { r in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text(r.title ?? r.outcome).font(.caption).lineLimit(2)
                            Text(r.date.formatted(date: .abbreviated, time: .shortened)).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if let url = r.pullRequestURL.flatMap(URL.init(string:)) {
                            Button("PR") { openURL(url) }.controlSize(.small)
                        } else if let log = r.logPath {
                            Button("Log") { NSWorkspace.shared.open(URL(fileURLWithPath: log)) }.controlSize(.small)
                        }
                    }
                }
            }

            Divider()
            HStack {
                Button("Settings...") { SettingsWindow.show() }
                Button("Website") { openURL(URL(string: "https://the-opus-project.github.io")!) }
                Spacer()
                Button("Quit") {
                    c.stopRun()
                    NSApp.terminate(nil)
                }
            }
        }
        .padding(14)
        .frame(width: 340)
    }
}

struct SettingsView: View {
    @EnvironmentObject var c: Controller

    var body: some View {
        Form {
            Section("Agent") {
                Picker("Run with", selection: $c.settings.agent) {
                    ForEach(AgentKind.allCases) { Text($0.displayName).tag($0) }
                }
                TextField("Model", text: $c.settings.model, prompt: Text("Agent default"))
                Stepper("Stop a run after \(c.settings.maxRunMinutes) min", value: $c.settings.maxRunMinutes, in: 20...480, step: 10)
            }
            Section("When to run") {
                Toggle("Only while charging", isOn: $c.settings.requireCharging)
                Stepper(c.settings.idleMinutes == 0 ? "Run even while I'm using the Mac" : "Only after \(c.settings.idleMinutes) min idle",
                        value: $c.settings.idleMinutes, in: 0...120, step: 5)
            }
            Section("Usage limits") {
                Picker("Use", selection: $c.settings.quotaMode) {
                    ForEach(QuotaMode.allCases) { Text($0.displayName).tag($0) }
                }
                if c.settings.quotaMode == .leftover {
                    Stepper("Start \(c.settings.leftoverHours) h before the weekly reset", value: $c.settings.leftoverHours, in: 1...96)
                } else {
                    Stepper("Stop at \(c.settings.weeklyCapPercent)% of the weekly limit", value: $c.settings.weeklyCapPercent, in: 5...100, step: 5)
                }
                Stepper("Pause at \(c.settings.fiveHourCapPercent)% of the 5-hour limit", value: $c.settings.fiveHourCapPercent, in: 10...100, step: 5)
                if let u = c.usage {
                    Text("Now: \(u.summary())").font(.caption).foregroundStyle(.secondary)
                }
            }
            Section("Contributions") {
                Toggle("Open pull requests from my GitHub account", isOn: $c.settings.openPullRequests)
                Toggle("Start OPUS Helper when I log in", isOn: Binding(get: { c.launchAtLogin }, set: { c.setLaunchAtLogin($0) }))
            }
            Section("Setup") {
                ForEach(c.prerequisites) { p in
                    HStack {
                        Image(systemName: p.ok ? "checkmark.circle.fill" : (p.required ? "xmark.circle.fill" : "minus.circle"))
                            .foregroundStyle(p.ok ? .green : (p.required ? .red : .secondary))
                        Text(p.name)
                        Spacer()
                        Text(p.detail).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle)
                    }.font(.caption)
                }
                Button("Check again") { c.refreshPrerequisites() }
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .padding(.vertical, 8)
    }
}

@MainActor
enum SettingsWindow {
    static var window: NSWindow?

    static func show() {
        if window == nil {
            let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 480, height: 600),
                             styleMask: [.titled, .closable], backing: .buffered, defer: false)
            w.title = "OPUS Helper Settings"
            w.isReleasedWhenClosed = false
            w.contentView = NSHostingView(rootView: SettingsView().environmentObject(Controller.shared))
            w.center()
            window = w
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
