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
fileprivate let adventOfCodeEnd: Date = {
    var components = DateComponents()
    components.year = adventOfCodeYear
    components.month = 12
    components.day = 26
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
            },
            "times": { [unowned self] _, output in
                // Present best times per day

                withLeaderboard(output: output) { board in
                    output.append(.compound([
                        (try? self.presentTimesGraph(board: board)).map { .image($0) },
                        try .embed(self.presentTimesEmbed(board: board))
                    ].compactMap { $0 }))
                }
            },
            "participation": { [unowned self] _, output in
                // Present participation numbers per day

                withLeaderboard(output: output) { board in
                    try output.append(self.presentParticipationGraph(board: board))
                }
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

            withLeaderboard(output: output) { board in
                output.append(.compound([
                    (try? self.presentStarGraph(board: board)).map { .image($0) },
                    try .embed(self.presentScoreEmbed(board: board))
                ].compactMap { $0 }))
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

    private func withLeaderboard(output: CommandOutput, _ action: @escaping (AdventOfCodeLeaderboard) throws -> Void) {
        guard let ownerId = configuration.leaderboardOwnerId else {
            output.append(errorText: "Please set a leaderboard before querying it!")
            return
        }
        AdventOfCodeLeaderboardQuery(event: adventOfCodeEvent, ownerId: ownerId).perform().listen {
            do {
                try action($0.get())
            } catch {
                output.append(error, errorText: "Could not query/process leaderboard.")
            }
        }
    }

    private func presentStarGraph(board: AdventOfCodeLeaderboard) throws -> Image {
        let topMembers = board.members.values.sorted(by: descendingComparator(comparing: \.stars)).prefix(28)
        var graph = LineGraph<Double, Double>(enablePrimaryAxisGrid: true)
        let start = board.startDate ?? adventOfCodeStart

        for member in topMembers {
            let base = AdventOfCodeLeaderboard.Member.StarScore(score: 0, date: start)
            let scores = [base] + zip([base] + member.starScores, member.starScores)
                .flatMap { (score, next) in [score.at(date: next.date - 0.0000001), next] }
                .sorted()

            if scores.count > 1 {
                graph.addSeries(
                    scores.map { $0.date.timeIntervalSince(start).asDays + 1 },
                    scores.map(\.score).map(Double.init),
                    label: member.displayName,
                    color: .init(Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), 1)
                )
            }
        }

        graph.plotLineThickness = 3
        return try render(plot: graph)
    }

    private func presentParticipationGraph(board: AdventOfCodeLeaderboard) throws -> Image {
        var graph = BarGraph<Int, Double>()
        let calendar = Calendar.current
        let startDay = calendar.component(.day, from: board.startDate ?? adventOfCodeStart)
        let endDay = calendar.component(.day, from: min(Date(), board.endDate ?? adventOfCodeEnd))
        let days = startDay...endDay
        let participations = days.map { day in board.members.values.count(forWhich: { $0.starCompletions.keys.contains(day) }) }

        graph.addSeries(
            Array(days),
            participations.map(Double.init),
            label: "Participants"
        )

        return try render(plot: graph)
    }

    private func presentTimesGraph(board: AdventOfCodeLeaderboard) throws -> Image {
        let topMembers = board.members.values.sorted(by: descendingComparator(comparing: \.stars)).prefix(28)
        var graph = LineGraph<Double, Double>(enablePrimaryAxisGrid: true)
        let calendar = Calendar.current
        let startDay = calendar.component(.day, from: board.startDate ?? adventOfCodeStart)
        let endDay = calendar.component(.day, from: min(Date(), board.endDate ?? adventOfCodeEnd))

        for member in topMembers {
            let times = (startDay...endDay).compactMap { day in board.timeToCompletion(member: member, day: day).map { (day, $0) } }

            if times.count > 1 {
                graph.addSeries(
                    times.map(\.0).map(Double.init),
                    times.map(\.1),
                    label: member.displayName,
                    color: .init(Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), 1)
                )
            }
        }

        graph.plotLineThickness = 3
        return try render(plot: graph)
    }

    private func render<P>(plot: P) throws -> Image where P: Plot {
        let renderer = AGGRenderer()
        plot.drawGraph(renderer: renderer)

        guard let pngData = Data(base64Encoded: renderer.base64Png()) else {
            throw AdventOfCodeError.noPlotImageData
        }

        return try Image(fromPng: pngData)
    }

    private func presentScoreEmbed(board: AdventOfCodeLeaderboard) throws -> Embed {
        let topMembers = board.members.values
            .sorted(by: descendingComparator { $0.localScore ?? 0 })
            .prefix(15)

        return Embed(
            title: ":christmas_tree: Advent of Code \(adventOfCodeEvent) Leaderboard - Top \(topMembers.count)",
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

    private func presentTimesEmbed(board: AdventOfCodeLeaderboard) throws -> Embed {
        let day = Calendar.current.component(.day, from: min(Date(), board.endDate ?? Date.distantFuture))
        let topMembers = Dictionary(grouping: board.members.values
            .map { ($0, board.timesToCompletion(member: $0, day: day)) }
            .flatMap { (member, ttcs) -> [(String, (time: TimeInterval, member: AdventOfCodeLeaderboard.Member))] in
                [
                    ttcs.reduce1(+).map { [("Total", $0)] } ?? [],
                    ttcs.enumerated().map { (i, ttc) in ("Part \(i + 1)", ttc) }
                ].flatMap { $0 }.map { (name, ttc) in (name, (time: ttc, member: member)) }
            }, by: \.0)
            .mapValues { $0.map(\.1) }
            .sorted(by: ascendingComparator(comparing: \.key))

        return Embed(
            title: ":stopwatch: Advent of Code \(adventOfCodeEvent) Best Times Today - Top \(topMembers.map(\.value.count).max() ?? 0)",
            fields: topMembers.map { (name, tms) in
                Embed.Field(
                    name: name,
                    value: tms
                        .sorted(by: ascendingComparator { $0.time })
                        .prefix(15)
                        .enumerated()
                        .map { (i, tm) in "`\(String(format: "%02d", i + 1)). \(format(timeInterval: tm.time))` | **\(tm.member.displayName)**" }
                        .joined(separator: "\n")
                        .nilIfEmpty
                        ?? "_no one here yet :(_"
                )
            }
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
