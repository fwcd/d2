import D2MessageIO
import D2NetAPIs
import Foundation
import SwiftPlot
import AGGRenderer
@preconcurrency import CairoGraphics
import Utils

nonisolated(unsafe) private let subcommandPattern = #/(?<name>[\w-]+)\s*(?<args>.*)/#

public class AdventOfCodeCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches a private Advent of Code leaderboard",
        presented: true,
        requiredPermissionLevel: .basic
    )
    @AutoSerializing(filePath: "local/adventOfCodeConfig.json") private var configuration: AdventOfCodeConfiguration = .init()
    private var subcommands: [String: (String, CommandOutput) async -> Void] = [:]

    private var dateRange: Range<Date> {
        var components = DateComponents()
        components.month = 12
        components.day = 1
        components.hour = 6
        components.minute = 0
        guard let start = Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime, direction: .backward) else {
            fatalError("No Advent of Code start date found!")
        }
        guard let end = Calendar.current.date(bySetting: .day, value: 26, of: start) else {
            fatalError("No Advent of Code end date found!")
        }
        return start..<end
    }
    private var startDate: Date { dateRange.lowerBound }
    private var endDate: Date { dateRange.upperBound }
    private var year: Int { Calendar.current.component(.year, from: startDate) }
    private var event: String { String(year) }

    public init() {
        subcommands = [
            "set-leaderboard": { [unowned self] args, output in
                guard let id = Int(args) else {
                    await output.append(errorText: "Please specify a leaderboard id!")
                    return
                }

                configuration.leaderboardOwnerId = id
                await output.append("Successfully set leaderboard to owner id `\(id)`!")
            },
            "unset-leaderboard": { [unowned self] _, output in
                configuration.leaderboardOwnerId = nil
                await output.append("Successfully unset leaderboard!")
            },
            "times": { [unowned self] _, output in
                // Present best times per day

                await withLeaderboard(output: output) { board in
                    await output.append(.compound([
                        (try? self.presentTimesGraph(board: board)).map { .image($0) },
                        try .embed(self.presentTimesEmbed(board: board))
                    ].compactMap { $0 }))
                }
            },
            "participation": { [unowned self] _, output in
                // Present participation numbers per day

                await withLeaderboard(output: output) { board in
                    try await output.append(self.presentParticipationGraph(board: board))
                }
            }
        ]
        info.helpText = """
            Syntax: `[subcommand] [args...]`

            Available Subcommands:
            \(subcommands.keys.map { "- `\($0)`" }.joined(separator: "\n"))
            """
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        if input.isEmpty {
            // Present leaderboard

            await withLeaderboard(output: output) { board in
                await output.append(.compound([
                    (try? self.presentStarGraph(board: board)).map { .image($0) },
                    try .embed(self.presentScoreEmbed(board: board))
                ].compactMap { $0 }))
            }
        } else {
            // Invoke subcommand
            guard let parsedSubcommand = try? subcommandPattern.firstMatch(in: input) else {
                await output.append(errorText: info.helpText!)
                return
            }
            let subcommandName = String(parsedSubcommand.name)
            let subcommandArgs = String(parsedSubcommand.args)
            guard let subcommand = subcommands[subcommandName] else {
                await output.append(errorText: "Unknown subcommand `\(subcommandName)`, try one of these: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))")
                return
            }
            await subcommand(subcommandArgs, output)
        }
    }

    private func withLeaderboard(output: any CommandOutput, _ action: @escaping (AdventOfCodeLeaderboard) async throws -> Void) async {
        guard let ownerId = configuration.leaderboardOwnerId else {
            await output.append(errorText: "Please set a leaderboard before querying it!")
            return
        }
        do {
            let board = try await AdventOfCodeLeaderboardQuery(event: event, ownerId: ownerId).perform()
            try await action(board)
        } catch {
            await output.append(error, errorText: "Could not query/process leaderboard.")
        }
    }

    private func presentStarGraph(board: AdventOfCodeLeaderboard) throws -> CairoImage {
        let topMembers = extractTopMembers(count: 28, from: board)
        var graph = LineGraph<Double, Double>(enablePrimaryAxisGrid: true)
        let start = board.startDate ?? startDate

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

    private func presentParticipationGraph(board: AdventOfCodeLeaderboard) throws -> CairoImage {
        var graph = BarGraph<Int, Double>()
        let calendar = Calendar.current
        let startDay = calendar.component(.day, from: board.startDate ?? startDate)
        let endDay = calendar.component(.day, from: min(Date(), board.endDate ?? endDate))
        let days = startDay...endDay
        let participations = days.map { day in board.members.values.count(forWhich: { $0.starCompletions.keys.contains(day) }) }

        graph.addSeries(
            Array(days),
            participations.map(Double.init),
            label: "Participants"
        )

        return try render(plot: graph)
    }

    private func presentTimesGraph(board: AdventOfCodeLeaderboard) throws -> CairoImage {
        let topMembers = extractTopMembers(count: 28, from: board)
        var graph = LineGraph<Double, Double>(enablePrimaryAxisGrid: true)
        let calendar = Calendar.current
        let startDay = calendar.component(.day, from: board.startDate ?? startDate)
        let endDay = calendar.component(.day, from: min(Date(), board.endDate ?? endDate))

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

    private func render<P>(plot: P) throws -> CairoImage where P: Plot {
        let renderer = AGGRenderer()
        plot.drawGraph(renderer: renderer)

        guard let pngData = Data(base64Encoded: renderer.base64Png()) else {
            throw AdventOfCodeError.noPlotImageData
        }

        return try CairoImage(pngData: pngData)
    }

    private func presentScoreEmbed(board: AdventOfCodeLeaderboard) throws -> Embed {
        let topMembers = extractTopMembers(count: 15, from: board)

        return Embed(
            title: ":christmas_tree: Advent of Code \(event) Leaderboard - Top \(topMembers.count)",
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
        let day = board.currentChallengeDay()
        let maxTopMembers = 15
        let topMembers = Dictionary(grouping: board.members.values
            .map { ($0, board.timesToCompletion(member: $0, day: day)) }
            .flatMap { (member, ttcs) -> [(String, (time: TimeInterval, member: AdventOfCodeLeaderboard.Member))] in
                var components = [
                    ttcs.enumerated().map { (i, ttc) in ("Part \(i + 1)", ttc) }
                ]
                if ttcs.count == AdventOfCodeLeaderboard.starsPerDay {
                    // Only show totals for those who completed the day
                    components.append(ttcs.reduce1(+).map { [("Total", $0)] } ?? [])
                }
                return components
                    .flatMap { $0 }
                    .map { (name, ttc) in (name, (time: ttc, member: member)) }
            }, by: \.0)
            .mapValues { $0.map(\.1) }
            .sorted(by: ascendingComparator(comparing: \.key))

        return Embed(
            title: ":stopwatch: Advent of Code \(event) Best Times for Day \(day) - Top \(min(topMembers.map(\.value.count).max() ?? 0, maxTopMembers))",
            fields: topMembers.map { (name, tms) in
                Embed.Field(
                    name: name,
                    value: tms
                        .sorted(by: ascendingComparator { $0.time })
                        .prefix(maxTopMembers)
                        .enumerated()
                        .map { (i, tm) in "`\(String(format: "%02d", i + 1)). \(format(timeInterval: tm.time))` | **\(tm.member.displayName)**" }
                        .joined(separator: "\n")
                        .nilIfEmpty
                        ?? "_no one here yet :(_"
                )
            }
        )
    }

    private func extractTopMembers(count: Int, from board: AdventOfCodeLeaderboard) -> [AdventOfCodeLeaderboard.Member] {
        Array(board.members.values
            .sorted(by: descendingComparator { $0.localScore ?? 0 })
            .prefix(count))
    }

    private func format(timeInterval: TimeInterval) -> String {
        let total = Int(timeInterval)
        let seconds = total % 60
        let minutes = (total / 60) % 60
        let hours = total / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
