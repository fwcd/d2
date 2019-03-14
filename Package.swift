// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "D2",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/nuclearace/SwiftDiscord.git", .revision("77a9cf9e99e64a54b9f61588c2e82675523b5c2b"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "D2",
            dependencies: ["SwiftDiscord"]),
        .testTarget(
            name: "D2Tests",
            dependencies: ["D2"]),
    ]
)
