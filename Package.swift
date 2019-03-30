// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "D2",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/nuclearace/SwiftDiscord.git", .upToNextMajor(from: "9.0.0")),
        .package(url: "https://github.com/kelvin13/png.git", .upToNextMajor(from: "3.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "D2",
            dependencies: ["SwiftDiscord", "D2Utils", "D2Permissions", "D2Commands"]
        ),
        .target(
            name: "D2Commands",
            dependencies: ["SwiftDiscord", "D2Utils", "D2Permissions", "D2WebAPIs"]
        ),
        .target(
            name: "D2Permissions",
            dependencies: ["SwiftDiscord", "D2Utils"]
        ),
        .target(
            name: "D2WebAPIs",
            dependencies: ["D2Utils"]
        ),
        .target(
            name: "D2Utils",
            dependencies: ["SwiftDiscord", "PNG"]
        ),
        .testTarget(
            name: "D2CommandTests",
            dependencies: ["SwiftDiscord", "D2TestUtils", "D2Commands"]
        ),
        .testTarget(
            name: "D2TestUtils",
            dependencies: ["SwiftDiscord", "D2Commands"]
        )
    ]
)
