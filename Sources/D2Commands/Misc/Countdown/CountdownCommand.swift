import Foundation
import D2MessageIO
import D2Permissions
import Utils

private func makeDateFormatter(_ format: String) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter
}

private let outputDateFormatter = makeDateFormatter("dd.MM.yyyy - HH:mm")
private let inputDateFormatters = [
    makeDateFormatter("dd.MM.yyyy"),
    makeDateFormatter("dd.MM.yyyy HH:mm"),
    outputDateFormatter
]
nonisolated(unsafe) private let subcommandPattern = #/(?<name>\w+)\s*(?<args>.*)/#
nonisolated(unsafe) private let namedDatePattern = #/(?<name>\w+[\sa-zA-Z]+)\s+(?<date>.+)/#

public class CountdownCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "A date/time countdown manager",
        longDescription: "Stores a collection of dates that it counts down to",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed
    private var subcommands: [String: (String, CommandOutput) async -> Void] = [:]

    @AutoSerializing(filePath: "local/countdownGoals.json") private var userGoals: [String: FixedCountdownGoal] = [:]
    private var builtInGoals: [String: CountdownGoal]
    private var goals: [String: CountdownGoal] { builtInGoals.merging(userGoals) { v, _ in v } }

    public init(builtInGoals: [String: CountdownGoal] = [:]) {
        self.builtInGoals = builtInGoals

        subcommands = [
            "add": { [unowned self] input, output in
                guard let parsedInput = try? namedDatePattern.firstMatch(in: input) else {
                    await output.append(errorText: "Please use the format: [name] [dd.MM.yyyy] [HH:mm]?")
                    return
                }

                let name = String(parsedInput.name)
                let rawDate = String(parsedInput.date)

                guard !goals.keys.contains(name) else {
                    await output.append(errorText: "A goal with name `\(name)` already exists!")
                    return
                }
                guard let date = self.parseDate(from: rawDate) else {
                    await output.append(errorText: "Could not parse date. Please use one of these formats: `\(inputDateFormatters.compactMap { $0.dateFormat })`")
                    return
                }

                let goal = FixedCountdownGoal(date: date)
                self.userGoals[name] = goal
                await self.show(name, as: goal, to: output)
            },
            "remove": { [unowned self] input, output in
                if let goal = self.userGoals.removeValue(forKey: input) {
                    await output.append(":x: Removed goal `\(input)` (on: \(outputDateFormatter.string(from: goal.date)))")
                } else {
                    await output.append(errorText: ":question: No user-defined goal named `\(input)` is currently running")
                }
            }
        ]
        info.helpText = makeHelpText()
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        if let date = parseDate(from: input) {
            await show("Anonymous Event", as: FixedCountdownGoal(date: date), to: output)
        } else if let parsedArgs = try? subcommandPattern.firstMatch(in: input) {
            let subcommandName = String(parsedArgs.name)
            let subcommandArgs = String(parsedArgs.args)

            guard let subcommand = subcommands[subcommandName] else {
                await output.append(errorText: "Could not find subcommand with name \(subcommandName)")
                return
            }

            await subcommand(subcommandArgs, output)
        } else {
            removeCompletedGoals() // Clean up
            await showRunningGoals(to: output)
        }
    }

    private func parseDate(from input: String) -> Date? {
        return inputDateFormatters.compactMap { $0.date(from: input) }.first
    }

    private func show(_ name: String, as goal: CountdownGoal, to output: any CommandOutput) async {
        await output.append(.embed(Embed(
            title: ":hourglass: \(name) Countdown",
            description: "The next \(name) will take place in **\(describeRemainingTimeUntil(goal: goal))**",
            footer: Embed.Footer(text: outputDateFormatter.string(from: goal.date))
        )))
    }

    private func showRunningGoals(to output: any CommandOutput) async {
        await output.append(.embed(Embed(
            title: ":hourglass: Running Countdowns",
            fields: goals.map { Embed.Field(name: $0.key, value: "will take place in **\(describeRemainingTimeUntil(goal: $0.value))** (on \(outputDateFormatter.string(from: $0.value.date)))") }
        )))
    }

    private func describeRemainingTimeUntil(goal: CountdownGoal) -> String {
        let date = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: goal.date)
        let days = date.day!
        let hours = date.hour!
        let minutes = date.minute!

        return "\(days) \("day".pluralized(with: days)), \(hours) \("hour".pluralized(with: hours)) and \(minutes) \("minute".pluralized(with: minutes))"
    }

    private func removeCompletedGoals() {
        userGoals = userGoals.filter { !$0.value.hasCompleted }
    }

    private func makeHelpText() -> String {
        return "Available subcommands: \(subcommands.keys)"
    }
}
