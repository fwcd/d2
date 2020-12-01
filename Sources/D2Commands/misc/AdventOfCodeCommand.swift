import D2MessageIO
import D2NetAPIs
import Foundation
import SwiftPlot
import AGGRenderer
import Graphics
import Utils

fileprivate let subcommandPattern = try! Regex(from: "([\\w-]+)\\s*(.*)")
fileprivate let adventOfCodeEvent = "2020"

public class AdventOfCodeCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches a private Advent of Code leaderboard",
        requiredPermissionLevel: .vip
    )
    @AutoSerializing(filePath: "local/adventOfCode\(adventOfCodeEvent)Config.json") private var configuration: AdventOfCodeConfiguration = .init()
    private var subcommands: [String: (String, CommandOutput) -> Void] = [:]

    public init() {
        subcommands = [
            "set-leaderboard": { [unowned self] args, output in
                guard let id = Int(args) else {
                    output.append(errorText: "Please specify a leaderboard id!")
                    return
                }

                configuration.leaderboardOwnerId = id
                output.append("Successfully set leaderboard to owner id `\(id)`!")
            },
            "unset-leaderboard": { [unowned self] _, output in
                configuration.leaderboardOwnerId = nil
                output.append("Successfully unset leaderboard!")
            }
        ]
        info.helpText = """
            Syntax: `[subcommand] [args...]`

            Available Subcommands:
            \(subcommands.keys.map { "- `\($0)`" }.joined(separator: "\n"))
            """
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        if input.isEmpty {
            // Present leaderboard
            guard let ownerId = configuration.leaderboardOwnerId else {
                output.append(errorText: "Please set a leaderboard before querying it!")
                return
            }

            AdventOfCodeLeaderboardQuery(event: adventOfCodeEvent, ownerId: ownerId).perform().listen {
                do {
                    let board = try $0.get()
                    let n = 15
                    let topMembers = Array(board.members.values
                        .sorted(by: descendingComparator(comparing: \.stars))
                        .prefix(n))

                    output.append(RichValue.compound([
                        (try? self.presentAsGraph(members: topMembers)).map { RichValue.image($0) },
                        try RichValue.embed(self.presentAsEmbed(members: topMembers))
                    ].compactMap { $0 }))
                } catch {
                    output.append(error, errorText: "Could not query leaderboard")
                }
            }
        } else {
            // Invoke subcommand
            guard let parsedSubcommand = subcommandPattern.firstGroups(in: input) else {
                output.append(errorText: info.helpText!)
                return
            }
            let subcommandName = parsedSubcommand[1]
            let subcommandArgs = parsedSubcommand[2]
            guard let subcommand = subcommands[subcommandName] else {
                output.append(errorText: "Unknown subcommand `\(subcommandName)`, try one of these: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))")
                return
            }
            subcommand(subcommandArgs, output)
        }
    }

    private func presentAsGraph(members: [AdventOfCodeLeaderboard.Member]) throws -> Image {
        let renderer = AGGRenderer()
        var graph = LineGraph<Double, Double>(enablePrimaryAxisGrid: true)

        for member in members {
            let stars = member.starsPerDayCumulative
            if stars.count >= 2 {
                graph.addSeries(stars.indices.map { Double($0 + 1) }, stars.map(Double.init), label: member.displayName)
            }
        }

        graph.plotLineThickness = 3
        graph.drawGraph(renderer: renderer)

        guard let pngData = Data(base64Encoded: renderer.base64Png()) else {
            throw AdventOfCodeError.noPlotImageData
        }
        let image = try Image(fromPng: pngData)

        return image
    }

    private func presentAsEmbed(members: [AdventOfCodeLeaderboard.Member]) throws -> Embed {
        Embed(
            title: "Advent of Code \(adventOfCodeEvent) Leaderboard - Top \(members.count)",
            description: members
                .map { "**\($0.displayName)**: \($0.stars) :star:" }
                .joined(separator: "\n")
                .nilIfEmpty
                ?? "_no one here yet :(_"
        )
    }
}
