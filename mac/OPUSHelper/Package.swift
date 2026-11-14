// swift-tools-version:5.9
import PackageDescription

var targets: [Target] = [
    .target(name: "OPUSHelperCore", path: "Sources/OPUSHelperCore"),
    .testTarget(name: "OPUSHelperCoreTests", dependencies: ["OPUSHelperCore"], path: "Tests/OPUSHelperCoreTests"),
]
#if os(macOS)
targets.append(.executableTarget(name: "OPUSHelper", dependencies: ["OPUSHelperCore"], path: "Sources/OPUSHelper"))
#endif

let package = Package(
    name: "OPUSHelper",
    platforms: [.macOS(.v14)],
    targets: targets
)
