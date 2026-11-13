import Foundation

public let upstreamRepo = "the-opus-project/the-opus-project.github.io"

public struct Prerequisite: Identifiable {
    public var id: String { name }
    public var name: String
    public var ok: Bool
    public var required: Bool
    public var detail: String
    public var fix: String?
}

public enum Prerequisites {
    public static func check(_ settings: HelperSettings, tools: ToolEnvironment) -> [Prerequisite] {
        var list: [Prerequisite] = []
        let git = tools.run("git", ["--version"], timeout: 20)
        list.append(Prerequisite(name: "Git", ok: git.ok, required: true,
                                 detail: git.ok ? git.stdout.trimmingCharacters(in: .whitespacesAndNewlines) : "Not installed",
                                 fix: "xcode-select --install"))
        let py = tools.run("python3", ["-c", "import sys; print(sys.version.split()[0])"], timeout: 20)
        list.append(Prerequisite(name: "Python 3", ok: py.ok, required: true,
                                 detail: py.ok ? "Python \(py.stdout.trimmingCharacters(in: .whitespacesAndNewlines))" : "Not installed",
                                 fix: "xcode-select --install"))
        if tools.find("gh") == nil {
            list.append(Prerequisite(name: "GitHub CLI", ok: false, required: settings.openPullRequests,
                                     detail: "Not installed", fix: "brew install gh && gh auth login"))
        } else {
            let auth = tools.run("gh", ["api", "user", "--jq", ".login"], timeout: 30)
            list.append(Prerequisite(name: "GitHub CLI", ok: auth.ok, required: settings.openPullRequests,
                                     detail: auth.ok ? "Signed in as @\(auth.stdout.trimmingCharacters(in: .whitespacesAndNewlines))" : "Not signed in",
                                     fix: "gh auth login"))
        }
        let agentPath = tools.find(settings.agent.executableName)
        list.append(Prerequisite(name: settings.agent.displayName, ok: agentPath != nil, required: true,
                                 detail: agentPath ?? "Not installed",
                                 fix: settings.agent == .codex ? "brew install --cask codex && codex login" : "curl -fsSL https://claude.ai/install.sh | bash && claude"))
        let ly = tools.run("lilypond", ["--version"], timeout: 30)
        list.append(Prerequisite(name: "LilyPond", ok: ly.ok, required: true,
                                 detail: ly.ok ? (ly.stdout.split(separator: "\n").first.map(String.init) ?? "installed") : "Not installed",
                                 fix: "brew install lilypond"))
        let docker = tools.run("docker", ["info", "--format", "{{.ServerVersion}}"], timeout: 20)
        list.append(Prerequisite(name: "Docker (optional)", ok: docker.ok, required: false,
                                 detail: docker.ok ? "Running" : "Not running; the repository check runs on GitHub instead",
                                 fix: nil))
        return list
    }
}

public struct RunOptions {
    public var openPullRequest: Bool
    public var maxMinutes: Int
    public init(openPullRequest: Bool, maxMinutes: Int) {
        self.openPullRequest = openPullRequest
        self.maxMinutes = maxMinutes
    }
}

public final class ContributionRunner {
    let store: HelperStore
    let tools: ToolEnvironment
    let settings: HelperSettings
    let options: RunOptions
    let logURL: URL
    private var log: FileHandle?
    public var onStatus: ((String) -> Void)?

    public init(store: HelperStore, tools: ToolEnvironment, settings: HelperSettings, options: RunOptions) {
        self.store = store
        self.tools = tools
        self.settings = settings
        self.options = options
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd-HHmmss"
        f.locale = Locale(identifier: "en_US_POSIX")
        logURL = store.logsURL.appendingPathComponent("run-\(f.string(from: Date())).log")
    }

    var repo: URL { store.repoURL }

    func say(_ s: String) {
        let line = "[opus-helper \(ISO8601DateFormatter().string(from: Date()))] \(s)\n"
        log?.seekToEndOfFile()
        log?.write(line.data(using: .utf8)!)
        onStatus?(s)
    }

    @discardableResult
    func git(_ args: [String], timeout: TimeInterval = 300) throws -> String {
        let r = tools.run("git", args, cwd: repo, timeout: timeout)
        if !r.ok { throw RunError("git \(args.first ?? "") failed: \(r.stderr.prefix(400))") }
        return r.stdout
    }

    public func run(shouldStop: @escaping () -> Bool) -> ContributionRecord {
        FileManager.default.createFile(atPath: logURL.path, contents: nil)
        log = try? FileHandle(forWritingTo: logURL)
        defer { try? log?.close() }
        var record = ContributionRecord(date: Date(), agent: settings.agent, outcome: "Failed", logPath: logURL.path)
        do {
            try prepareRepo()
            let skip = excludedPieces()
            say("Skipping pieces: \(skip.isEmpty ? "none" : skip.sorted().joined(separator: ", "))")
            let prompt = buildPrompt(skip: skip)
            say("Starting \(settings.agent.displayName)")
            let (status, stopped, timedOut) = try runAgent(prompt: prompt, shouldStop: shouldStop)
            if stopped {
                say("Stopped before finishing; discarding partial work")
                record.outcome = "Stopped"
                try? resetRepo()
                return record
            }
            if timedOut { say("Time limit of \(options.maxMinutes) min reached") }
            say("\(settings.agent.displayName) exited with status \(status)")
            let result = try finish()
            record.outcome = result.outcome
            record.title = result.title
            record.pullRequestURL = result.url
        } catch let e as RunError {
            say("Error: \(e.message)")
            record.outcome = "Failed: \(e.message)"
        } catch {
            say("Error: \(error)")
            record.outcome = "Failed: \(error.localizedDescription)"
        }
        return record
    }

    func prepareRepo() throws {
        let fm = FileManager.default
        if !fm.fileExists(atPath: repo.appendingPathComponent(".git").path) {
            say("Cloning the OPUS repository")
            try? fm.removeItem(at: repo)
            let r = tools.run("git", ["clone", "https://github.com/\(upstreamRepo).git", repo.path], cwd: store.directory, timeout: 900)
            if !r.ok { throw RunError("clone failed: \(r.stderr.prefix(400))") }
        }
        say("Updating the repository")
        try git(["fetch", "--prune", "origin"])
        try resetRepo()
    }

    func resetRepo() throws {
        try git(["checkout", "--force", "--detach", "origin/main"])
        try git(["reset", "--hard", "origin/main"])
        try git(["clean", "-fdx", "--quiet"])
    }

    func excludedPieces() -> Set<String> {
        guard tools.find("gh") != nil else { return [] }
        var slugs = Set<String>()
        for extra in [["--state", "open"], ["--state", "all", "--author", "@me"]] {
            let r = tools.run("gh", ["pr", "list", "-R", upstreamRepo, "--limit", "300", "--json", "files"] + extra, timeout: 90)
            guard r.ok, let data = r.stdout.data(using: .utf8),
                  let prs = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { continue }
            for pr in prs {
                for f in (pr["files"] as? [[String: Any]]) ?? [] {
                    if let p = f["path"] as? String { if let s = Self.slug(p) { slugs.insert(s) } }
                }
            }
        }
        return slugs
    }

    static func slug(_ path: String) -> String? {
        let parts = path.split(separator: "/")
        guard parts.count >= 3, parts[0] == "pieces" else { return nil }
        return String(parts[1])
    }

    func modelHint() -> String {
        if !settings.model.isEmpty {
            return settings.model.contains("/") ? settings.model : "\(settings.agent == .codex ? "openai" : "anthropic")/\(settings.model)"
        }
        if settings.agent == .codex {
            let home = ProcessInfo.processInfo.environment["CODEX_HOME"].flatMap { $0.isEmpty ? nil : $0 } ?? NSHomeDirectory() + "/.codex"
            let cfg = URL(fileURLWithPath: home).appendingPathComponent("config.toml")
            if let text = try? String(contentsOf: cfg, encoding: .utf8) {
                for line in text.split(separator: "\n") {
                    let t = line.trimmingCharacters(in: .whitespaces)
                    if t.hasPrefix("[") { break }
                    if t.hasPrefix("model") && !t.hasPrefix("model_") , let q1 = t.firstIndex(of: "\"") {
                        let rest = t[t.index(after: q1)...]
                        if let q2 = rest.firstIndex(of: "\"") { return "openai/\(rest[..<q2])" }
                    }
                }
            }
        }
        return ""
    }

    public func buildPrompt(skip: Set<String>) -> String {
        let docker = tools.run("docker", ["info", "--format", "{{.ServerVersion}}"], timeout: 20).ok
        let lily = tools.find("lilypond") ?? "lilypond"
        let model = modelHint()
        let modelLine = model.isEmpty
            ? "`Model: provider/exact-model-id` with the exact identifier of the model you are running as"
            : "`Model: \(model)`"
        return """
        You are running unattended from OPUS Helper, a background app on a volunteer's Mac. Nobody is watching and nobody can answer questions, so never ask for input; decide and keep working.

        Contribute exactly one bounded piece of work to The OPUS Project. Read AGENTS.md and HANDBOOK.md in this repository and follow them as if the contributor had said "help The OPUS Project". Do the full required self-review: render your LilyPond and compare it with the printed scan bar by bar before you finish.

        Do not work on these pieces, because another pull request is already open for them or this contributor already worked on them, and steps 1, 2 and 3 must come from different contributors: \(skip.isEmpty ? "(none)" : skip.sorted().joined(separator: ", ")).

        Practical notes for this machine:
        - LilyPond is at \(lily). Keep scans and rendered PDFs outside the repository (for example in $TMPDIR) and never commit them.
        - \(docker ? "Docker is running, so run `python3 scripts/check.py --write` at the end and fix every failure." : "Docker is not available, so `scripts/check.py` cannot run here. Compile with the LilyPond above instead; OPUS Helper regenerates catalog.json and GitHub runs the full check.")
        - Pull requests contain only scores: change only LilyPond files and metadata.json under pieces/ (and wanted.txt if you take a work from it). Do not add Markdown, review notes or other prose files, and do not edit documentation, scripts, workflows or website files. Put your review notes in your final message instead.
        - Do not run git commit, git push or gh. OPUS Helper commits your changes and opens the pull request.

        When you are done, write a file named OPUS_PR.md at the repository root. Its first line is the pull request title, for example "Add step 1 transcription of <work>". The rest is the pull request body and must contain exactly these lines and nothing else:
        Source: https://... (the printed source URL)
        Step: N/3
        \(modelLine)

        If you cannot produce a valid, self-reviewed contribution, undo your changes and do not write OPUS_PR.md.
        """
    }

    func runAgent(prompt: String, shouldStop: @escaping () -> Bool) throws -> (Int32, Bool, Bool) {
        guard let exe = tools.find(settings.agent.executableName) else { throw RunError("\(settings.agent.displayName) is not installed") }
        var args: [String]
        switch settings.agent {
        case .codex:
            args = ["exec", "--sandbox", "workspace-write", "-c", "sandbox_workspace_write.network_access=true",
                    "--color", "never", "-C", repo.path]
            if !settings.model.isEmpty { args += ["-m", settings.model] }
            args.append(prompt)
        case .claude:
            args = ["-p", prompt, "--permission-mode", "bypassPermissions", "--output-format", "text"]
            if !settings.model.isEmpty { args += ["--model", settings.model] }
        }
        var env = tools.environment
        env["OPUS_HELPER"] = "1"
        log?.seekToEndOfFile()
        let proc = try SpawnedProcess(executable: exe, arguments: args, cwd: repo.path, environment: env, logPath: logURL.path)
        let r = proc.wait(timeout: TimeInterval(max(10, options.maxMinutes) * 60), shouldStop: shouldStop)
        kill(-proc.pid, SIGKILL)
        return r
    }

    struct Finish {
        var outcome: String
        var title: String?
        var url: String?
    }

    func finish() throws -> Finish {
        let prFile = repo.appendingPathComponent("OPUS_PR.md")
        let prText = try? String(contentsOf: prFile, encoding: .utf8)
        try? FileManager.default.removeItem(at: prFile)

        let status = try git(["status", "--porcelain", "--untracked-files=all"])
        var dropped: [String] = []
        for line in status.split(separator: "\n") {
            let path = String(line.dropFirst(3)).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            let target = path.components(separatedBy: " -> ").last ?? path
            if !Self.allowed(target) { dropped.append(target) }
        }
        for p in dropped {
            say("Discarding change outside the allowed files: \(p)")
            _ = tools.run("git", ["checkout", "--", p], cwd: repo)
            _ = tools.run("git", ["clean", "-fdq", "--", p], cwd: repo)
        }
        if !dropped.isEmpty { say("Kept only LilyPond, metadata.json, catalog.json and wanted.txt") }
        let ignoredJunk = try git(["status", "--porcelain", "--ignored", "--untracked-files=all", "pieces"])
        for line in ignoredJunk.split(separator: "\n") where line.hasPrefix("!! ") {
            try? FileManager.default.removeItem(at: repo.appendingPathComponent(String(line.dropFirst(3))))
        }

        guard let prText, !prText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            try resetRepo()
            return Finish(outcome: "No contribution (the agent did not finish a reviewed piece)")
        }
        let remaining = try git(["status", "--porcelain", "--untracked-files=all"])
        if remaining.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            try resetRepo()
            return Finish(outcome: "No contribution (no score files changed)")
        }
        let (title, body) = Self.splitPR(prText)
        guard Self.validBody(body) else {
            say("OPUS_PR.md is missing Source, Step or Model lines:\n\(prText)")
            try resetRepo()
            return Finish(outcome: "Failed: pull request details were incomplete")
        }

        let catalog = tools.run("python3", ["-B", "-c", "import sys; sys.path.insert(0, 'scripts'); import check; open('catalog.json', 'w', encoding='utf-8').write(check.render_catalog(check.expected_catalog()[0]))"], cwd: repo, timeout: 120)
        if !catalog.ok { say("Could not regenerate catalog.json: \(catalog.stderr.prefix(400))") }

        let branch = "opus-helper/\(Int(Date().timeIntervalSince1970))"
        try git(["checkout", "-b", branch])
        try git(["add", "-A", "--", "pieces", "catalog.json", "wanted.txt"])
        let identity = gitIdentity()
        try git(["-c", "user.name=\(identity.name)", "-c", "user.email=\(identity.email)", "commit", "--quiet", "-m", title,
                 "-m", "Generated by \(settings.agent.displayName) through OPUS Helper."])
        say("Committed \(title)")

        guard options.openPullRequest else {
            return Finish(outcome: "Committed locally on \(branch) (pull requests are off)", title: title)
        }
        let url = try openPullRequest(branch: branch, title: title, body: body)
        say("Opened \(url)")
        return Finish(outcome: "Pull request opened", title: title, url: url)
    }

    static func allowed(_ path: String) -> Bool {
        if path == "catalog.json" || path == "wanted.txt" { return true }
        guard path.hasPrefix("pieces/") else { return false }
        return path.hasSuffix(".ly") || path.hasSuffix("/metadata.json")
    }

    static func splitPR(_ text: String) -> (String, String) {
        var lines = text.replacingOccurrences(of: "\r\n", with: "\n").split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        while let f = lines.first, f.trimmingCharacters(in: .whitespaces).isEmpty { lines.removeFirst() }
        var title = lines.isEmpty ? "OPUS contribution" : lines.removeFirst()
        title = title.trimmingCharacters(in: CharacterSet(charactersIn: "# ")).trimmingCharacters(in: .whitespaces)
        if title.isEmpty || title.hasPrefix("Source:") { title = "OPUS contribution" }
        let body = lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        return (String(title.prefix(200)), body)
    }

    static func validBody(_ body: String) -> Bool {
        let lines = body.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
        let source = lines.contains { $0.hasPrefix("Source: https://") }
        let step = lines.contains { $0.range(of: #"^Step: [123]/3$"#, options: .regularExpression) != nil }
        let model = lines.contains { $0.range(of: #"^Model: [A-Za-z0-9._-]+/[A-Za-z0-9._:-]+$"#, options: .regularExpression) != nil }
        return source && step && model
    }

    func gitIdentity() -> (name: String, email: String) {
        let name = tools.run("git", ["config", "--global", "user.name"]).stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = tools.run("git", ["config", "--global", "user.email"]).stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        if !name.isEmpty && !email.isEmpty { return (name, email) }
        let r = tools.run("gh", ["api", "user", "--jq", "[.login, (.id|tostring)] | join(\" \")"], timeout: 30)
        let parts = r.stdout.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ")
        if r.ok, parts.count == 2 { return (String(parts[0]), "\(parts[1])+\(parts[0])@users.noreply.github.com") }
        return ("OPUS Helper", "opus-helper@users.noreply.github.com")
    }

    func openPullRequest(branch: String, title: String, body: String) throws -> String {
        guard let gh = tools.find("gh") else { throw RunError("GitHub CLI is not installed") }
        let login = tools.run("gh", ["api", "user", "--jq", ".login"], timeout: 30).stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        if login.isEmpty { throw RunError("GitHub CLI is not signed in") }
        let repoName = upstreamRepo.split(separator: "/")[1]
        var forkName = ""
        for attempt in 0..<12 {
            let r = tools.run("gh", ["api", "repos/\(login)/\(repoName)", "--jq", "select(.fork) | .full_name"], timeout: 30)
            let name = r.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            if r.ok && !name.isEmpty { forkName = name; break }
            if attempt == 0 {
                say("Creating your fork of the repository")
                let f = tools.run("gh", ["repo", "fork", upstreamRepo, "--clone=false", "--default-branch-only"], timeout: 120)
                let out = (f.stdout + f.stderr)
                if let m = out.range(of: #"[A-Za-z0-9-]+/[A-Za-z0-9._-]+"#, options: .regularExpression), out.contains("already exists") {
                    let candidate = String(out[m])
                    if candidate.hasPrefix(login + "/") { forkName = candidate; break }
                }
            }
            Thread.sleep(forTimeInterval: 5)
        }
        if forkName.isEmpty { throw RunError("could not find or create your fork") }
        say("Pushing \(branch) to \(forkName)")
        try git(["-c", "credential.helper=", "-c", "credential.helper=!\"\(gh)\" auth git-credential",
                 "push", "https://github.com/\(forkName).git", "HEAD:refs/heads/\(branch)"], timeout: 600)
        let owner = forkName.split(separator: "/")[0]
        let pr = tools.run("gh", ["pr", "create", "-R", upstreamRepo, "--base", "main", "--head", "\(owner):\(branch)",
                                  "--title", title, "--body", body], cwd: repo, timeout: 120)
        if !pr.ok { throw RunError("gh pr create failed: \(pr.stderr.prefix(400))") }
        return pr.stdout.split(separator: "\n").last.map(String.init)?.trimmingCharacters(in: .whitespaces) ?? ""
    }
}

public struct RunError: Error {
    public var message: String
    public init(_ m: String) { message = m }
}
