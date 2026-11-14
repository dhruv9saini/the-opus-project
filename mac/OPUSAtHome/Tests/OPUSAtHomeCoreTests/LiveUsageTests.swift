import XCTest
@testable import OPUSAtHomeCore

final class LiveUsageTests: XCTestCase {
    func testLiveUsage() throws {
        let env = ProcessInfo.processInfo.environment
        guard let agents = env["OPUS_LIVE_USAGE"] else { throw XCTSkip("set OPUS_LIVE_USAGE=codex,claude to read real usage") }
        let tools = ToolEnvironment(preferProcessPath: true)
        for name in agents.split(separator: ",") {
            guard let agent = AgentKind(rawValue: String(name)) else { continue }
            let (usage, error) = UsageReader.read(agent, tools: tools)
            print("LIVE \(agent.rawValue): \(usage.map { "\($0.summary()) blocked=\($0.blocked) 5h=\($0.fiveHour?.usedPercent ?? -1) week=\($0.weekly?.usedPercent ?? -1) weekReset=\(String(describing: $0.weekly?.resetsAt))" } ?? "nil") error=\(error ?? "none")")
            XCTAssertNotNil(usage, "\(agent.rawValue): \(error ?? "")")
            var s = AppSettings()
            s.enabled = true
            s.agent = agent
            for mode in QuotaMode.allCases {
                s.quotaMode = mode
                print("LIVE \(agent.rawValue) \(mode.rawValue): \(Policy.decide(s, Conditions(onCharger: true, idleSeconds: 0, usage: usage)))")
            }
        }
    }
}
