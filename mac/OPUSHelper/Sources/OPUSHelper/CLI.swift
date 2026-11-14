import Foundation
import OPUSHelperCore

enum CLI {
    static func handle(_ args: [String]) -> Int32? {
        guard let cmd = args.first, cmd.hasPrefix("--"), !cmd.hasPrefix("-NS"), !cmd.hasPrefix("-Apple") else { return nil }
        let store = HelperStore()
        var settings = store.loadSettings()
        if let i = args.firstIndex(of: "--agent"), i + 1 < args.count, let a = AgentKind(rawValue: args[i + 1]) { settings.agent = a }
        if let i = args.firstIndex(of: "--model"), i + 1 < args.count { settings.model = args[i + 1] }
        if let i = args.firstIndex(of: "--minutes"), i + 1 < args.count, let m = Int(args[i + 1]) { settings.maxRunMinutes = m }
        let tools = ToolEnvironment(preferProcessPath: true)
        switch cmd {
        case "--status":
            print("Settings: \(store.settingsURL.path)")
            for p in Prerequisites.check(settings, tools: tools) {
                print("\(p.ok ? "ok  " : (p.required ? "MISSING" : "no  ")) \(p.name): \(p.detail)")
            }
            let charger = Power.onCharger()
            let idle = Power.idleSeconds()
            print("On charger: \(charger)  Idle: \(Int(idle)) s")
            let (u, err) = UsageReader.read(settings.agent, tools: tools)
            print("\(settings.agent.displayName) usage: \(u?.summary() ?? "unavailable (\(err ?? "?"))")")
            var s = settings
            s.enabled = true
            let d = Policy.decide(s, Conditions(onCharger: charger, idleSeconds: idle, usage: u))
            print("Would run now: \(d.run ? "yes" : "no") - \(d.reason)")
            return 0
        case "--prompt":
            let runner = ContributionRunner(store: store, tools: tools, settings: settings, options: RunOptions(openPullRequest: false, maxMinutes: settings.maxRunMinutes))
            print(runner.buildPrompt(skip: []))
            return 0
        case "--run-once":
            let open = !args.contains("--no-pr") && settings.openPullRequests
            let runner = ContributionRunner(store: store, tools: tools, settings: settings, options: RunOptions(openPullRequest: open, maxMinutes: settings.maxRunMinutes))
            runner.onStatus = { print($0) }
            let record = runner.run(shouldStop: { false })
            store.append(record)
            print("Outcome: \(record.outcome)")
            if let url = record.pullRequestURL { print("Pull request: \(url)") }
            print("Log: \(record.logPath ?? "")")
            return record.outcome.hasPrefix("Failed") ? 1 : 0
        case "--help":
            print("OPUS Helper\n  --status            show setup, power, usage and whether a run would start\n  --prompt            print the agent prompt\n  --run-once [--no-pr] [--agent codex|claude] [--model M] [--minutes N]")
            return 0
        default:
            return nil
        }
    }
}
