// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "D2",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(name: "D2", targets: ["D2"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // TODO: Use the upstream SwiftDiscord once vapor3 branch is merged
        .package(url: "https://github.com/fwcd/SwiftDiscord.git", .revision("a92297176c7678c3709a4376e1185dbe4f808b53")),
        .package(url: "https://github.com/givip/Telegrammer.git", .revision("32657287befddf3d303287bf319901f5c7a6f24e")),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/kylef/Commander.git", from: "0.9.1"),
        .package(url: "https://github.com/fwcd/swift-qrcode-generator.git", .revision("835a0005597380a0459fab9a8135616de355a992")),
        .package(url: "https://github.com/fwcd/swift-prolog.git", .revision("edc7aa228ed342c28f58e4036639562ac6c801f0")),
        .package(url: "https://github.com/fwcd/swift-utils.git", from: "1.3.2"),
        .package(url: "https://github.com/fwcd/swift-graphics.git", .revision("c7183ea8ca9de2d07750a209b23eba40ea91c375")),
        .package(url: "https://github.com/fwcd/swift-gif.git", .revision("9e0e383340b0ca28f6ce60a7a9e1e1d496a5f7d0")),
        .package(url: "https://github.com/swift-server/swift-backtrace.git", from: "1.1.1"),
        .package(name: "Emoji", url: "https://github.com/safx/Emoji-Swift.git", .revision("b3a49f4a9fbee3c7320591dbc7263c192244063e")),
        .package(name: "PerfectSysInfo", url: "https://github.com/PerfectlySoft/Perfect-SysInfo.git", from: "3.0.0"),
        .package(name: "SwiftPlot", url: "https://github.com/KarthikRIyer/swiftplot.git", from: "2.0.0"),
        // TODO: Update to an actual version number once the PR #5 is merged
        .package(name: "GraphViz", url: "https://github.com/fwcd/swift-graphviz.git", .revision("1dd2479ce6d97effd8b7ed5bc6f47b79d5340fef")),
        .package(url: "https://github.com/stephencelis/SQLite.swift", from: "0.12.2"),
        .package(url: "https://github.com/NozeIO/swift-nio-irc-client.git", from: "0.7.2"),
        .package(url: "https://github.com/MaxDesiatov/XMLCoder.git", from: "0.11.1"),
        .package(url: "https://github.com/wfreitag/syllable-counter-swift.git", .revision("029c8568b4d060174284fdedd7473863768a903b")),
        .package(url: "https://github.com/nmdias/FeedKit.git", from: "9.1.2"),
        .package(url: "https://github.com/SwiftyTesseract/SwiftyTesseract.git", from: "4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "D2",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Utils", package: "swift-utils"),
                .product(name: "Backtrace", package: "swift-backtrace"),
                .product(name: "Commander", package: "Commander"),
                .target(name: "D2Handlers"),
                .target(name: "D2DiscordIO"),
                .target(name: "D2TelegramIO"),
                .target(name: "D2IRCIO")
            ]
        ),
        .target(
            name: "D2DiscordIO",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Utils", package: "swift-utils"),
                .product(name: "SwiftDiscord", package: "SwiftDiscord"),
                .target(name: "D2MessageIO")
            ]
        ),
        .target(
            name: "D2TelegramIO",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Utils", package: "swift-utils"),
                .product(name: "Emoji", package: "Emoji"),
                .product(name: "Telegrammer", package: "Telegrammer"),
                .target(name: "D2MessageIO")
            ]
        ),
        .target(
            name: "D2IRCIO",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Utils", package: "swift-utils"),
                .product(name: "IRC", package: "swift-nio-irc-client"),
                .product(name: "Emoji", package: "Emoji"),
                .target(name: "D2MessageIO")
            ]
        ),
        .target(
            name: "D2Handlers",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Utils", package: "swift-utils"),
                .product(name: "SyllableCounter", package: "syllable-counter-swift"),
                .target(name: "D2MessageIO"),
                .target(name: "D2Permissions"),
                .target(name: "D2Commands")
            ]
        ),
        .target(
            name: "D2Commands",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Utils", package: "swift-utils"),
                .product(name: "QRCodeGenerator", package: "swift-qrcode-generator"),
                .product(name: "PrologInterpreter", package: "swift-prolog"),
                .product(name: "Graphics", package: "swift-graphics"),
                .product(name: "GIF", package: "swift-gif"),
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                .product(name: "FeedKit", package: "FeedKit"),
                .product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "GraphViz", package: "GraphViz"),
                .product(name: "PerfectSysInfo", package: "PerfectSysInfo"),
                .product(name: "SwiftPlot", package: "SwiftPlot"),
                .product(name: "AGGRenderer", package: "SwiftPlot"),
                .product(name: "SwiftyTesseract", package: "SwiftyTesseract"),
                .target(name: "D2MessageIO"),
                .target(name: "D2Permissions"),
                .target(name: "D2Script"),
                .target(name: "D2NetAPIs")
            ]
        ),
        .target(
            name: "D2Permissions",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Utils", package: "swift-utils"),
                .target(name: "D2MessageIO")
            ]
        ),
        .target(
            name: "D2Script",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Utils", package: "swift-utils")
            ]
        ),
        .target(
            name: "D2NetAPIs",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Utils", package: "swift-utils"),
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                .product(name: "XMLCoder", package: "XMLCoder")
            ]
        ),
        .target(
            name: "D2MessageIO",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Utils", package: "swift-utils"),
                .product(name: "Graphics", package: "swift-graphics"),
                .product(name: "GIF", package: "swift-gif")
            ]
        ),
        .testTarget(
            name: "D2CommandTests",
            dependencies: [
                .product(name: "Utils", package: "swift-utils"),
                .target(name: "D2TestUtils"),
                .target(name: "D2MessageIO"),
                .target(name: "D2Commands")
            ]
        ),
        .testTarget(
            name: "D2ScriptTests",
            dependencies: [
                .product(name: "Utils", package: "swift-utils"),
                .target(name: "D2Script")
            ]
        ),
        .testTarget(
            name: "D2NetAPITests",
            dependencies: [
                .target(name: "D2MessageIO"),
                .target(name: "D2TestUtils"),
                .target(name: "D2NetAPIs")
            ]
        ),
        .testTarget(
            name: "D2TestUtils",
            dependencies: [
                .target(name: "D2MessageIO"),
                .target(name: "D2Commands")
            ]
        )
    ]
)
