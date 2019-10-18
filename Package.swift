// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "D2",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // TODO: Use the upstream SwiftDiscord once vapor3 branch is merged
        .package(url: "https://github.com/nuclearace/SwiftDiscord.git", .revision("6f8503520e028cae17e06efd53f60b04585414a2")),
        .package(url: "https://github.com/PureSwift/Cairo.git", .revision("b5f867a56a20d2f0064ccb975ae4a669b374e9e0")),
        .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.0.0")
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
            dependencies: ["SwiftDiscord", "SwiftSoup", "D2Utils", "D2Permissions", "D2Graphics", "D2Script", "D2WebAPIs"]
        ),
        .target(
            name: "D2Permissions",
            dependencies: ["SwiftDiscord", "D2Utils"]
        ),
        .target(
            name: "D2Script",
            dependencies: ["D2Utils"]
        ),
        .target(
            name: "D2WebAPIs",
            dependencies: ["D2Utils"]
        ),
        .target(
            name: "D2Graphics",
            dependencies: ["SwiftDiscord", "D2Utils", "Cairo"]
        ),
        .target(
            name: "D2Utils",
            dependencies: ["SwiftDiscord"]
        ),
        .testTarget(
            name: "D2CommandTests",
            dependencies: ["SwiftDiscord", "D2Utils", "D2TestUtils", "D2Commands"]
        ),
        .testTarget(
            name: "D2ScriptTests",
            dependencies: ["D2Utils", "D2Script"]
        ),
        .testTarget(
            name: "D2UtilsTests",
            dependencies: ["SwiftDiscord", "D2Utils", "D2TestUtils"]
        ),
        .testTarget(
            name: "D2GraphicsTests",
            dependencies: ["SwiftDiscord", "D2TestUtils", "D2Graphics"]
        ),
        .testTarget(
            name: "D2WebAPITests",
            dependencies: ["SwiftDiscord", "D2TestUtils", "D2WebAPIs"]
        ),
        .testTarget(
            name: "D2TestUtils",
            dependencies: ["SwiftDiscord", "D2Commands"]
        )
    ]
)
