import Foundation

public struct UsageWindow: Equatable {
    public var usedPercent: Double
    public var resetsAt: Date?

    public init(usedPercent: Double, resetsAt: Date?) {
        self.usedPercent = usedPercent
        self.resetsAt = resetsAt
    }
}

public struct Usage: Equatable {
    public var fiveHour: UsageWindow?
    public var weekly: UsageWindow?
    public var blocked = false

    public init(fiveHour: UsageWindow?, weekly: UsageWindow?, blocked: Bool = false) {
        self.fiveHour = fiveHour
        self.weekly = weekly
        self.blocked = blocked
    }

    public func summary(now: Date = Date()) -> String {
        var parts: [String] = []
        if let f = fiveHour { parts.append("5-hour \(Int(f.usedPercent.rounded()))%") }
        if let w = weekly {
            var s = "week \(Int(w.usedPercent.rounded()))%"
            if let r = w.resetsAt { s += " (resets \(Usage.relative(r, now: now)))" }
            parts.append(s)
        }
        return parts.isEmpty ? "unknown" : parts.joined(separator: ", ")
    }

    public static func relative(_ date: Date, now: Date = Date()) -> String {
        let s = date.timeIntervalSince(now)
        if s <= 0 { return "now" }
        let h = Int(s / 3600)
        if h >= 48 { return "in \(h / 24) days" }
        if h >= 1 { return "in \(h) h" }
        return "in \(max(1, Int(s / 60))) min"
    }
}

public enum UsageParser {
    public static func codex(_ data: Data) -> Usage? {
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        let result = (obj["result"] as? [String: Any]) ?? obj
        guard let snap = result["rateLimits"] as? [String: Any] else { return nil }
        var windows: [(mins: Double, w: UsageWindow)] = []
        for key in ["primary", "secondary"] {
            guard let w = snap[key] as? [String: Any], let used = number(w["usedPercent"]) else { continue }
            let mins = number(w["windowDurationMins"]) ?? (key == "primary" ? 300 : 10080)
            let reset = number(w["resetsAt"]).map { Date(timeIntervalSince1970: $0) }
            windows.append((mins, UsageWindow(usedPercent: used, resetsAt: reset)))
        }
        var usage = Usage(fiveHour: nil, weekly: nil)
        for item in windows {
            if item.mins >= 1440 { usage.weekly = item.w } else { usage.fiveHour = item.w }
        }
        if snap["rateLimitReachedType"] is String { usage.blocked = true }
        if let allowed = result["ordinaryUsageAllowed"] as? Bool, !allowed { usage.blocked = true }
        if usage.fiveHour == nil && usage.weekly == nil { return nil }
        return usage
    }

    public static func claude(_ data: Data) -> Usage? {
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        func window(_ key: String) -> UsageWindow? {
            guard let w = obj[key] as? [String: Any], let used = number(w["utilization"]) else { return nil }
            return UsageWindow(usedPercent: used, resetsAt: (w["resets_at"] as? String).flatMap(parseDate))
        }
        let usage = Usage(fiveHour: window("five_hour"), weekly: window("seven_day"))
        if usage.fiveHour == nil && usage.weekly == nil { return nil }
        return usage
    }

    static func number(_ v: Any?) -> Double? {
        if let n = v as? NSNumber { return n.doubleValue }
        if let s = v as? String { return Double(s) }
        return nil
    }

    static func parseDate(_ s: String) -> Date? {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f.date(from: s) { return d }
        f.formatOptions = [.withInternetDateTime]
        return f.date(from: s)
    }
}

public struct Conditions {
    public var onCharger: Bool
    public var idleSeconds: Double
    public var usage: Usage?
    public var now: Date
    public var backoffUntil: Date?

    public init(onCharger: Bool, idleSeconds: Double, usage: Usage?, now: Date = Date(), backoffUntil: Date? = nil) {
        self.onCharger = onCharger
        self.idleSeconds = idleSeconds
        self.usage = usage
        self.now = now
        self.backoffUntil = backoffUntil
    }
}

public struct Decision: Equatable {
    public var run: Bool
    public var reason: String
}

public enum Policy {
    public static func gates(_ s: HelperSettings, _ c: Conditions) -> Decision? {
        if !s.enabled { return Decision(run: false, reason: "Off") }
        if s.requireCharging && !c.onCharger { return Decision(run: false, reason: "Waiting for the charger") }
        if s.idleMinutes > 0 && c.idleSeconds < Double(s.idleMinutes * 60) {
            return Decision(run: false, reason: "Waiting until the Mac has been idle \(s.idleMinutes) min")
        }
        if let until = c.backoffUntil, until > c.now {
            return Decision(run: false, reason: "Resting until \(timeString(until))")
        }
        return nil
    }

    public static func decide(_ s: HelperSettings, _ c: Conditions) -> Decision {
        gates(s, c) ?? quota(s, c.usage, now: c.now)
    }

    public static func quota(_ s: HelperSettings, _ usage: Usage?, now: Date) -> Decision {
        guard let u = usage else {
            if s.quotaMode == .leftover {
                return Decision(run: false, reason: "Can't read \(s.agent.displayName) usage, so leftover quota is unknown")
            }
            return Decision(run: true, reason: "Usage unknown; running")
        }
        if u.blocked { return Decision(run: false, reason: "\(s.agent.displayName) usage limit reached") }
        if let f = u.fiveHour, f.usedPercent >= Double(s.fiveHourCapPercent) {
            return Decision(run: false, reason: "5-hour usage at \(Int(f.usedPercent))%, waiting for it to reset")
        }
        guard let w = u.weekly else {
            if s.quotaMode == .leftover { return Decision(run: false, reason: "Weekly reset time unknown") }
            return Decision(run: true, reason: "Running")
        }
        switch s.quotaMode {
        case .leftover:
            if w.usedPercent >= leftoverStopPercent { return Decision(run: false, reason: "Weekly quota used up") }
            guard let reset = w.resetsAt else { return Decision(run: false, reason: "Weekly reset time unknown") }
            let window = Double(s.leftoverHours) * 3600
            if reset.timeIntervalSince(now) > window {
                return Decision(run: false, reason: "Saving quota until \(s.leftoverHours) h before the weekly reset (\(Usage.relative(reset, now: now)))")
            }
            return Decision(run: true, reason: "Using leftover weekly quota")
        case .anytime:
            if w.usedPercent >= Double(s.weeklyCapPercent) {
                return Decision(run: false, reason: "Weekly usage at \(Int(w.usedPercent))%, cap is \(s.weeklyCapPercent)%")
            }
            return Decision(run: true, reason: "Running")
        }
    }

    public static let leftoverStopPercent = 98.0

    public static func stopReason(_ s: HelperSettings, _ usage: Usage?) -> String? {
        guard let u = usage else { return nil }
        if u.blocked { return "\(s.agent.displayName) usage limit reached" }
        if let f = u.fiveHour, f.usedPercent >= Double(s.fiveHourCapPercent) {
            return "5-hour usage reached \(Int(f.usedPercent))%"
        }
        if let w = u.weekly {
            let cap = s.quotaMode == .leftover ? leftoverStopPercent : Double(s.weeklyCapPercent)
            if w.usedPercent >= cap { return "Weekly usage reached \(Int(w.usedPercent))%" }
        }
        return nil
    }

    static func timeString(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f.string(from: d)
    }
}
