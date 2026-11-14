// swift-tools-version:5.9
import PackageDescription

var targets: [Target] = [
    .target(name: "OPUSAtHomeCore", path: "Sources/OPUSAtHomeCore"),
    .testTarget(name: "OPUSAtHomeCoreTests", dependencies: ["OPUSAtHomeCore"], path: "Tests/OPUSAtHomeCoreTests"),
]
#if os(macOS)
targets.append(.executableTarget(name: "OPUSAtHome", dependencies: ["OPUSAtHomeCore"], path: "Sources/OPUSAtHome"))
#endif

let package = Package(
    name: "OPUSAtHome",
    platforms: [.macOS(.v14)],
    targets: targets
)
