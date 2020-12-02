import D2MessageIO
import D2NetAPIs
import Foundation
import SwiftPlot
import AGGRenderer
import Graphics
import Utils

fileprivate let subcommandPattern = try! Regex(from: "([\\w-]+)\\s*(.*)")
fileprivate let adventOfCodeYear: Int = 2020
fileprivate let adventOfCodeEvent: String = String(adventOfCodeYear)
fileprivate let adventOfCodeStart: Date = {
    var components = DateComponents()
    components.year = adventOfCodeYear
    components.month = 12
    components.day = 1
    return Calendar.current.date(from: components)!
}()

public class AdventOfCodeCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches a private Advent of Code leaderboard",
        requiredPermissionLevel: .basic
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

                    output.append(RichValue.compound([
                        (try? self.presentAsGraph(board: board)).map { RichValue.image($0) },
                        try RichValue.embed(self.presentAsEmbed(board: board))
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

    private func presentAsGraph(board: AdventOfCodeLeaderboard) throws -> Image {
        let topMembers = board.members.values.sorted(by: descendingComparator(comparing: \.stars)).prefix(28)
        let renderer = AGGRenderer()
        var graph = LineGraph<Double, Double>(enablePrimaryAxisGrid: true)
        let now = Date()

        for member in topMembers {
            var scores = member.starScores.flatMap { [$0.shortlyBefore, $0] }

            if let last = scores.last {
                scores.insert(.init(score: 0, date: adventOfCodeStart), at: 0)
                scores.append(.init(score: last.score, date: now))

                graph.addSeries(scores.map(\.date.timeIntervalSince1970), scores.map(\.score).map(Double.init), label: member.displayName, color: .random())
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

    private func presentAsEmbed(board: AdventOfCodeLeaderboard) throws -> Embed {
        let topMembers = board.members.values.sorted(by: descendingComparator { $0.localScore ?? 0 }).prefix(15)
        return Embed(
            title: "Advent of Code \(adventOfCodeEvent) Leaderboard - Top \(topMembers.count)",
            description: topMembers
                .enumerated()
                .map { (i, member) in [
                    "`\(String(format: "%02d", i + 1)). \(member.localScore ?? 0) | \(format(timeInterval: board.lastTimeToCompletion(member: member) ?? 0)) | \(member.stars)`",
                    ":star: **\(member.displayName)**"
                 ].compactMap { $0 }.joined(separator: " ") }
                .joined(separator: "\n")
                .nilIfEmpty
                ?? "_no one here yet :(_"
        )
    }

    private func format(timeInterval: TimeInterval) -> String {
        let total = Int(timeInterval)
        let seconds = total % 60
        let minutes = (total / 60) % 60
        let hours = total / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
