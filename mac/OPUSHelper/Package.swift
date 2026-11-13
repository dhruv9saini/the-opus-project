// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "OPUSHelper",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "OPUSHelperCore", path: "Sources/OPUSHelperCore"),
        .executableTarget(
            name: "OPUSHelper",
            dependencies: ["OPUSHelperCore"],
            path: "Sources/OPUSHelper"
        ),
        .testTarget(
            name: "OPUSHelperCoreTests",
            dependencies: ["OPUSHelperCore"],
            path: "Tests/OPUSHelperCoreTests"
        ),
    ]
)
