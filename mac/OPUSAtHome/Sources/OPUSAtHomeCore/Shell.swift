import Foundation

public struct CommandResult {
    public var status: Int32
    public var stdout: String
    public var stderr: String
    public var ok: Bool { status == 0 }
}

public final class ToolEnvironment {
    public let path: String
    public let environment: [String: String]

    public init(preferProcessPath: Bool = false) {
        var env = ProcessInfo.processInfo.environment
        let home = NSHomeDirectory()
        var dirs: [String] = []
        let processDirs = (env["PATH"] ?? "").split(separator: ":").map(String.init)
        if preferProcessPath { dirs += processDirs }
        if let shellPath = ToolEnvironment.loginShellPath() { dirs += shellPath.split(separator: ":").map(String.init) }
        dirs += processDirs
        dirs += ["/opt/homebrew/bin", "/usr/local/bin", "\(home)/.local/bin", "\(home)/.npm-global/bin",
                 "\(home)/.bun/bin", "\(home)/.volta/bin", "\(home)/.local/share/pnpm",
                 "/Applications/LilyPond.app/Contents/Resources/bin", "/usr/bin", "/bin", "/usr/sbin", "/sbin"]
        var seen = Set<String>()
        let joined = dirs.filter { !$0.isEmpty && seen.insert($0).inserted }.joined(separator: ":")
        env["PATH"] = joined
        path = joined
        environment = env
    }

    static func loginShellPath() -> String? {
        let shell = ProcessInfo.processInfo.environment["SHELL"].flatMap { $0.isEmpty ? nil : $0 } ?? "/bin/zsh"
        guard FileManager.default.isExecutableFile(atPath: shell) else { return nil }
        let r = Shell.run(shell, ["-l", "-i", "-c", "printf '__OPUS_PATH__%s__END__' \"$PATH\""], timeout: 10)
        guard let a = r.stdout.range(of: "__OPUS_PATH__"),
              let b = r.stdout.range(of: "__END__", range: a.upperBound..<r.stdout.endIndex) else { return nil }
        return String(r.stdout[a.upperBound..<b.lowerBound])
    }

    public func find(_ name: String) -> String? {
        if name.hasPrefix("/") { return FileManager.default.isExecutableFile(atPath: name) ? name : nil }
        for dir in path.split(separator: ":") {
            let p = "\(dir)/\(name)"
            if FileManager.default.isExecutableFile(atPath: p) { return p }
        }
        return nil
    }

    public func run(_ name: String, _ args: [String], cwd: URL? = nil, timeout: TimeInterval = 120, input: String? = nil) -> CommandResult {
        guard let exe = find(name) else { return CommandResult(status: 127, stdout: "", stderr: "\(name) not found") }
        return Shell.run(exe, args, cwd: cwd, env: environment, timeout: timeout, input: input)
    }
}

public enum Shell {
    public static func run(_ exe: String, _ args: [String], cwd: URL? = nil, env: [String: String]? = nil,
                           timeout: TimeInterval = 120, input: String? = nil) -> CommandResult {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: exe)
        p.arguments = args
        if let cwd { p.currentDirectoryURL = cwd }
        if let env { p.environment = env }
        let out = Pipe(), err = Pipe(), inp = Pipe()
        p.standardOutput = out
        p.standardError = err
        p.standardInput = inp
        var outData = Data(), errData = Data()
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async { outData = out.fileHandleForReading.readDataToEndOfFile(); group.leave() }
        group.enter()
        DispatchQueue.global().async { errData = err.fileHandleForReading.readDataToEndOfFile(); group.leave() }
        do { try p.run() } catch {
            return CommandResult(status: 126, stdout: "", stderr: "\(error)")
        }
        if let input { inp.fileHandleForWriting.write(input.data(using: .utf8) ?? Data()) }
        try? inp.fileHandleForWriting.close()
        let deadline = Date().addingTimeInterval(timeout)
        while p.isRunning && Date() < deadline { Thread.sleep(forTimeInterval: 0.05) }
        if p.isRunning {
            p.terminate()
            Thread.sleep(forTimeInterval: 1)
            if p.isRunning { kill(p.processIdentifier, SIGKILL) }
        }
        p.waitUntilExit()
        group.wait()
        return CommandResult(status: p.terminationStatus,
                             stdout: String(decoding: outData, as: UTF8.self),
                             stderr: String(decoding: errData, as: UTF8.self))
    }
}

public final class SpawnedProcess {
    public let pid: pid_t
    private var finished = false
    private var status: Int32 = 0
    private let lock = NSLock()

    public init(executable: String, arguments: [String], cwd: String, environment: [String: String], logPath: String, stdinPath: String = "/dev/null") throws {
        #if os(macOS)
        var fileActions: posix_spawn_file_actions_t? = nil
        var attr: posix_spawnattr_t? = nil
        #else
        var fileActions = posix_spawn_file_actions_t()
        var attr = posix_spawnattr_t()
        #endif
        posix_spawn_file_actions_init(&fileActions)
        defer { posix_spawn_file_actions_destroy(&fileActions) }
        posix_spawn_file_actions_addopen(&fileActions, 0, stdinPath, O_RDONLY, 0)
        posix_spawn_file_actions_addopen(&fileActions, 1, logPath, O_WRONLY | O_CREAT | O_APPEND, 0o644)
        posix_spawn_file_actions_adddup2(&fileActions, 1, 2)
        posix_spawnattr_init(&attr)
        defer { posix_spawnattr_destroy(&attr) }
        posix_spawnattr_setflags(&attr, Int16(POSIX_SPAWN_SETPGROUP))
        posix_spawnattr_setpgroup(&attr, 0)

        let fm = FileManager.default
        let previous = fm.currentDirectoryPath
        fm.changeCurrentDirectoryPath(cwd)
        defer { fm.changeCurrentDirectoryPath(previous) }

        let argv: [UnsafeMutablePointer<CChar>?] = ([executable] + arguments).map { strdup($0) } + [nil]
        let envp: [UnsafeMutablePointer<CChar>?] = environment.map { strdup("\($0.key)=\($0.value)") } + [nil]
        defer {
            argv.forEach { free($0) }
            envp.forEach { free($0) }
        }
        var newPid: pid_t = 0
        let rc = posix_spawn(&newPid, executable, &fileActions, &attr, argv, envp)
        if rc != 0 { throw NSError(domain: "OPUSAtHome", code: Int(rc), userInfo: [NSLocalizedDescriptionKey: "posix_spawn failed: \(String(cString: strerror(rc)))"]) }
        pid = newPid
    }

    public func poll() -> Int32? {
        lock.lock(); defer { lock.unlock() }
        if finished { return status }
        var st: Int32 = 0
        let r = waitpid(pid, &st, WNOHANG)
        if r == pid {
            finished = true
            status = (st & 0x7f) == 0 ? (st >> 8) & 0xff : 128 + (st & 0x7f)
            return status
        }
        return nil
    }

    public func wait(timeout: TimeInterval, shouldStop: () -> Bool) -> (status: Int32, stopped: Bool, timedOut: Bool) {
        let deadline = Date().addingTimeInterval(timeout)
        while true {
            if let s = poll() { return (s, false, false) }
            if shouldStop() { return (terminate(), true, false) }
            if Date() >= deadline { return (terminate(), false, true) }
            Thread.sleep(forTimeInterval: 0.5)
        }
    }

    @discardableResult
    public func terminate() -> Int32 {
        if let s = poll() { return s }
        kill(-pid, SIGINT)
        for _ in 0..<20 {
            Thread.sleep(forTimeInterval: 0.5)
            if let s = poll() { return s }
        }
        kill(-pid, SIGTERM)
        for _ in 0..<10 {
            Thread.sleep(forTimeInterval: 0.5)
            if let s = poll() { return s }
        }
        kill(-pid, SIGKILL)
        while poll() == nil { Thread.sleep(forTimeInterval: 0.2) }
        return poll() ?? -1
    }
}
