import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum UsageReader {
    public static func read(_ agent: AgentKind, tools: ToolEnvironment) -> (Usage?, String?) {
        switch agent {
        case .codex: return codex(tools)
        case .claude: return claude(tools)
        }
    }

    public static func codex(_ tools: ToolEnvironment) -> (Usage?, String?) {
        let lines = [
            #"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"clientInfo":{"name":"opus-helper","version":"1"}}}"#,
            #"{"jsonrpc":"2.0","method":"initialized"}"#,
            #"{"jsonrpc":"2.0","id":2,"method":"account/rateLimits/read"}"#,
        ]
        guard let exe = tools.find("codex") else { return (nil, "codex not found") }
        let p = Process()
        p.executableURL = URL(fileURLWithPath: exe)
        p.arguments = ["app-server"]
        p.environment = tools.environment
        p.currentDirectoryURL = FileManager.default.temporaryDirectory
        let inp = Pipe(), out = Pipe()
        p.standardInput = inp
        p.standardOutput = out
        p.standardError = FileHandle.nullDevice
        do { try p.run() } catch { return (nil, "\(error)") }
        inp.fileHandleForWriting.write((lines.joined(separator: "\n") + "\n").data(using: .utf8)!)

        var buffer = Data()
        var answer: Data?
        let deadline = Date().addingTimeInterval(25)
        let handle = out.fileHandleForReading
        let sem = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            while answer == nil {
                let chunk = handle.availableData
                if chunk.isEmpty { break }
                buffer.append(chunk)
                while let nl = buffer.firstIndex(of: 0x0A) {
                    let line = buffer.subdata(in: buffer.startIndex..<nl)
                    buffer.removeSubrange(buffer.startIndex...nl)
                    if let obj = try? JSONSerialization.jsonObject(with: line) as? [String: Any],
                       (obj["id"] as? NSNumber)?.intValue == 2 {
                        answer = line
                        break
                    }
                }
            }
            sem.signal()
        }
        _ = sem.wait(timeout: .now() + deadline.timeIntervalSinceNow)
        try? inp.fileHandleForWriting.close()
        if p.isRunning { p.terminate() }
        guard let answer else { return (nil, "Codex did not report usage") }
        if let obj = try? JSONSerialization.jsonObject(with: answer) as? [String: Any],
           let err = obj["error"] as? [String: Any] {
            return (nil, (err["message"] as? String).map { String($0.prefix(200)) } ?? "Codex usage error")
        }
        guard let usage = UsageParser.codex(answer) else { return (nil, "Codex usage was not in the expected format") }
        return (usage, nil)
    }

    public static func claudeToken(_ tools: ToolEnvironment) -> String? {
        var blobs: [String] = []
        let r = Shell.run("/usr/bin/security", ["find-generic-password", "-s", "Claude Code-credentials", "-w"], timeout: 15)
        if r.ok { blobs.append(r.stdout) }
        let file = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".claude/.credentials.json")
        if let s = try? String(contentsOf: file, encoding: .utf8) { blobs.append(s) }
        for blob in blobs {
            if let data = blob.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8),
               let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let oauth = obj["claudeAiOauth"] as? [String: Any],
               let token = oauth["accessToken"] as? String, !token.isEmpty {
                return token
            }
        }
        return nil
    }

    public static func claude(_ tools: ToolEnvironment) -> (Usage?, String?) {
        guard let token = claudeToken(tools) else { return (nil, "Claude Code is not signed in with a Claude subscription") }
        var req = URLRequest(url: URL(string: "https://api.anthropic.com/api/oauth/usage")!)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        req.timeoutInterval = 20
        var result: (Usage?, String?) = (nil, "Claude usage request failed")
        let sem = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: req) { data, resp, error in
            defer { sem.signal() }
            if let error { result = (nil, error.localizedDescription); return }
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            guard code == 200, let data else { result = (nil, "Claude usage request returned HTTP \(code)"); return }
            if let u = UsageParser.claude(data) { result = (u, nil) } else { result = (nil, "Claude usage was not in the expected format") }
        }.resume()
        _ = sem.wait(timeout: .now() + 25)
        return result
    }
}
