// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "D2",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/nuclearace/SwiftDiscord.git", .upToNextMajor(from: "9.0.0")),
        .package(url: "https://github.com/apple/swift-log.git", .revision("ef8cc5a5d5974b3b778a7d8b217e18ab424e0de5"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "D2",
            dependencies: ["SwiftDiscord", "Logging"]),
        .testTarget(
            name: "D2Tests",
            dependencies: ["D2"]),
    ]
)
