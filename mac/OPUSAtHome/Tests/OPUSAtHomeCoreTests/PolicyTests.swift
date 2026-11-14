import XCTest
@testable import OPUSAtHomeCore

final class PolicyTests: XCTestCase {
    let now = Date(timeIntervalSince1970: 1_800_000_000)

    func settings(_ mode: QuotaMode = .leftover) -> AppSettings {
        var s = AppSettings()
        s.enabled = true
        s.quotaMode = mode
        return s
    }

    func usage(five: Double = 10, week: Double = 40, resetIn hours: Double = 10) -> Usage {
        Usage(fiveHour: UsageWindow(usedPercent: five, resetsAt: now.addingTimeInterval(3600)),
              weekly: UsageWindow(usedPercent: week, resetsAt: now.addingTimeInterval(hours * 3600)))
    }

    func testOffAndCharger() {
        var s = settings()
        s.enabled = false
        XCTAssertFalse(Policy.decide(s, Conditions(onCharger: true, idleSeconds: 0, usage: usage(), now: now)).run)
        XCTAssertFalse(Policy.decide(settings(), Conditions(onCharger: false, idleSeconds: 0, usage: usage(), now: now)).run)
        var anywhere = settings()
        anywhere.requireCharging = false
        XCTAssertTrue(Policy.decide(anywhere, Conditions(onCharger: false, idleSeconds: 0, usage: usage(), now: now)).run)
    }

    func testIdle() {
        var s = settings()
        s.idleMinutes = 10
        XCTAssertFalse(Policy.decide(s, Conditions(onCharger: true, idleSeconds: 120, usage: usage(), now: now)).run)
        XCTAssertTrue(Policy.decide(s, Conditions(onCharger: true, idleSeconds: 700, usage: usage(), now: now)).run)
    }

    func testLeftover() {
        let s = settings(.leftover)
        XCTAssertTrue(Policy.decide(s, Conditions(onCharger: true, idleSeconds: 0, usage: usage(resetIn: 10), now: now)).run)
        XCTAssertFalse(Policy.decide(s, Conditions(onCharger: true, idleSeconds: 0, usage: usage(resetIn: 72), now: now)).run)
        XCTAssertFalse(Policy.decide(s, Conditions(onCharger: true, idleSeconds: 0, usage: usage(week: 100, resetIn: 5), now: now)).run)
        XCTAssertFalse(Policy.decide(s, Conditions(onCharger: true, idleSeconds: 0, usage: nil, now: now)).run)
        XCTAssertFalse(Policy.decide(s, Conditions(onCharger: true, idleSeconds: 0, usage: usage(five: 95), now: now)).run)
    }

    func testAnytime() {
        let s = settings(.anytime)
        XCTAssertTrue(Policy.decide(s, Conditions(onCharger: true, idleSeconds: 0, usage: usage(week: 40, resetIn: 100), now: now)).run)
        XCTAssertFalse(Policy.decide(s, Conditions(onCharger: true, idleSeconds: 0, usage: usage(week: 60, resetIn: 100), now: now)).run)
        XCTAssertTrue(Policy.decide(s, Conditions(onCharger: true, idleSeconds: 0, usage: nil, now: now)).run)
    }

    func testStopReason() {
        let leftover = settings(.leftover)
        XCTAssertNil(Policy.stopReason(leftover, usage(week: 97)))
        XCTAssertNotNil(Policy.stopReason(leftover, usage(week: 98)))
        XCTAssertNotNil(Policy.stopReason(leftover, usage(five: 95)))
        XCTAssertNotNil(Policy.stopReason(settings(.anytime), usage(week: 50)))
        XCTAssertNil(Policy.stopReason(leftover, nil))
        var blocked = usage()
        blocked.blocked = true
        XCTAssertNotNil(Policy.stopReason(leftover, blocked))
        let weeklyOnly = Usage(fiveHour: nil, weekly: UsageWindow(usedPercent: 12, resetsAt: now.addingTimeInterval(3600)))
        XCTAssertTrue(Policy.decide(leftover, Conditions(onCharger: true, idleSeconds: 0, usage: weeklyOnly, now: now)).run)
    }

    func testBackoff() {
        let c = Conditions(onCharger: true, idleSeconds: 0, usage: usage(), now: now, backoffUntil: now.addingTimeInterval(60))
        XCTAssertFalse(Policy.decide(settings(), c).run)
    }

    func testCodexParser() {
        let json = #"{"id":2,"result":{"rateLimits":{"primary":{"usedPercent":12,"windowDurationMins":300,"resetsAt":1800003600},"secondary":{"usedPercent":63,"windowDurationMins":10080,"resetsAt":1800050000}}}}"#
        let u = UsageParser.codex(Data(json.utf8))
        XCTAssertEqual(u?.fiveHour?.usedPercent, 12)
        XCTAssertEqual(u?.weekly?.usedPercent, 63)
        XCTAssertEqual(u?.weekly?.resetsAt, Date(timeIntervalSince1970: 1800050000))
        XCTAssertEqual(u?.blocked, false)
    }

    func testClaudeParser() {
        let json = #"{"five_hour":{"utilization":7.0,"resets_at":"2027-01-15T08:00:00.123+00:00"},"seven_day":{"utilization":81.5,"resets_at":"2027-01-17T05:00:00+00:00"}}"#
        let u = UsageParser.claude(Data(json.utf8))
        XCTAssertEqual(u?.fiveHour?.usedPercent, 7)
        XCTAssertEqual(u?.weekly?.usedPercent, 81.5)
        XCTAssertNotNil(u?.weekly?.resetsAt)
    }

    func testPullRequestBody() {
        let (title, body) = ContributionRunner.splitPR("# Add step 1 of Für Elise\n\nSource: https://imslp.org/x.pdf\nStep: 1/3\nModel: openai/gpt-6.1-sol\n")
        XCTAssertEqual(title, "Add step 1 of Für Elise")
        XCTAssertTrue(ContributionRunner.validBody(body))
        XCTAssertFalse(ContributionRunner.validBody("Source: https://x\nStep: 4/3\nModel: a/b"))
        XCTAssertFalse(ContributionRunner.validBody("Step: 1/3\nModel: a/b"))
    }

    func testAllowedPaths() {
        XCTAssertTrue(ContributionRunner.allowed("pieces/x/attempts/01.ly"))
        XCTAssertTrue(ContributionRunner.allowed("catalog.json"))
        XCTAssertTrue(ContributionRunner.allowed("pieces/x/metadata.json"))
        XCTAssertFalse(ContributionRunner.allowed("pieces/x/SELF_REVIEW.md"))
        XCTAssertFalse(ContributionRunner.allowed("scripts/check.py"))
        XCTAssertEqual(ContributionRunner.slug("pieces/abc/metadata.json"), "abc")
        XCTAssertNil(ContributionRunner.slug("pieces/abc"))
    }
}
