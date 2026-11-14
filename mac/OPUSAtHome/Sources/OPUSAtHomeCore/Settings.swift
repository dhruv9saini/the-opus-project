import Foundation

public enum AgentKind: String, Codable, CaseIterable, Identifiable {
    case codex
    case claude

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .codex: return "Codex"
        case .claude: return "Claude Code"
        }
    }

    public var executableName: String {
        switch self {
        case .codex: return "codex"
        case .claude: return "claude"
        }
    }
}

public enum QuotaMode: String, Codable, CaseIterable, Identifiable {
    case leftover
    case anytime

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .leftover: return "Only leftover quota before the weekly reset"
        case .anytime: return "Any time, up to a weekly cap"
        }
    }
}

public struct AppSettings: Codable, Equatable {
    public var enabled = false
    public var agent: AgentKind = .codex
    public var model = ""
    public var requireCharging = true
    public var idleMinutes = 0
    public var quotaMode: QuotaMode = .leftover
    public var leftoverHours = 24
    public var weeklyCapPercent = 50
    public var fiveHourCapPercent = 90
    public var maxRunMinutes = 120
    public var openPullRequests = true

    public init() {}

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let d = AppSettings()
        enabled = try c.decodeIfPresent(Bool.self, forKey: .enabled) ?? d.enabled
        agent = try c.decodeIfPresent(AgentKind.self, forKey: .agent) ?? d.agent
        model = try c.decodeIfPresent(String.self, forKey: .model) ?? d.model
        requireCharging = try c.decodeIfPresent(Bool.self, forKey: .requireCharging) ?? d.requireCharging
        idleMinutes = try c.decodeIfPresent(Int.self, forKey: .idleMinutes) ?? d.idleMinutes
        quotaMode = try c.decodeIfPresent(QuotaMode.self, forKey: .quotaMode) ?? d.quotaMode
        leftoverHours = try c.decodeIfPresent(Int.self, forKey: .leftoverHours) ?? d.leftoverHours
        weeklyCapPercent = try c.decodeIfPresent(Int.self, forKey: .weeklyCapPercent) ?? d.weeklyCapPercent
        fiveHourCapPercent = try c.decodeIfPresent(Int.self, forKey: .fiveHourCapPercent) ?? d.fiveHourCapPercent
        maxRunMinutes = try c.decodeIfPresent(Int.self, forKey: .maxRunMinutes) ?? d.maxRunMinutes
        openPullRequests = try c.decodeIfPresent(Bool.self, forKey: .openPullRequests) ?? d.openPullRequests
    }
}

public struct ContributionRecord: Codable, Identifiable, Equatable {
    public var id = UUID()
    public var date: Date
    public var agent: AgentKind
    public var outcome: String
    public var title: String?
    public var pullRequestURL: String?
    public var logPath: String?

    public init(date: Date, agent: AgentKind, outcome: String, title: String? = nil, pullRequestURL: String? = nil, logPath: String? = nil) {
        self.date = date
        self.agent = agent
        self.outcome = outcome
        self.title = title
        self.pullRequestURL = pullRequestURL
        self.logPath = logPath
    }
}

public final class DataStore {
    public let directory: URL
    public var settingsURL: URL { directory.appendingPathComponent("settings.json") }
    public var historyURL: URL { directory.appendingPathComponent("history.json") }
    public var repoURL: URL { directory.appendingPathComponent("repo") }
    public var logsURL: URL { directory.appendingPathComponent("logs") }

    public init(directory: URL? = nil) {
        if let directory {
            self.directory = directory
        } else if let env = ProcessInfo.processInfo.environment["OPUS_AT_HOME_HOME"], !env.isEmpty {
            self.directory = URL(fileURLWithPath: env)
        } else {
            let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Application Support")
            self.directory = base.appendingPathComponent("OPUS@Home")
        }
        try? FileManager.default.createDirectory(at: logsURL, withIntermediateDirectories: true)
    }

    public func loadSettings() -> AppSettings {
        guard let data = try? Data(contentsOf: settingsURL),
              let s = try? JSONDecoder().decode(AppSettings.self, from: data) else { return AppSettings() }
        return s
    }

    public func save(_ settings: AppSettings) {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? enc.encode(settings) { try? data.write(to: settingsURL, options: .atomic) }
    }

    public func loadHistory() -> [ContributionRecord] {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        guard let data = try? Data(contentsOf: historyURL),
              let h = try? dec.decode([ContributionRecord].self, from: data) else { return [] }
        return h
    }

    public func append(_ record: ContributionRecord) {
        var h = loadHistory()
        h.insert(record, at: 0)
        if h.count > 100 { h = Array(h.prefix(100)) }
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        enc.outputFormatting = [.prettyPrinted]
        if let data = try? enc.encode(h) { try? data.write(to: historyURL, options: .atomic) }
    }
}
