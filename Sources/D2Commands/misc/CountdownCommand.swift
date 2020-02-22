import Foundation
import SwiftDiscord
import D2Permissions
import D2Utils

fileprivate func makeDateFormatter(_ format: String) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter
}

fileprivate let outputDateFormatter = makeDateFormatter("dd.MM.yyyy - HH:mm")
fileprivate let inputDateFormatters = [
    makeDateFormatter("dd.MM.yyyy"),
    makeDateFormatter("dd.MM.yyyy HH:mm"),
    outputDateFormatter
]
fileprivate let subcommandPattern = try! Regex(from: "(\\w+)\\s*(.*)")
fileprivate let namedDatePattern = try! Regex(from: "(\\w+)\\s+(.+)")

public class CountdownCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "A date/time countdown manager",
        longDescription: "Stores a collection of dates that it counts down to",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed
    private var goals: [String: CountdownGoal]
    private var subcommands: [String: (String, CommandOutput) -> Void] = [:]
    
    public init(goals: [String: CountdownGoal] = [:]) {
        self.goals = goals

        subcommands = [
            "add": { [unowned self] input, output in
                guard let parsedInput = namedDatePattern.firstGroups(in: input) else {
                    output.append(errorText: "Please use the format: [name] [dd.MM.yyyy] [HH:mm]?")
                    return
                }

                let name = parsedInput[1]
                let rawDate = parsedInput[2]

                guard let date = self.parseDate(from: rawDate) else {
                    output.append(errorText: "Could not parse date. Please use one of these formats: `\(inputDateFormatters.compactMap { $0.dateFormat })`")
                    return
                }

                let goal = FixedCountdownGoal(date: date)
                self.goals[name] = goal
                self.show(name, as: goal, to: output)
            },
            "remove": { [unowned self] input, output in
                guard !(self.goals[input]?.protectedFromRemoval ?? false) else {
                    output.append(errorText: ":no_entry: `\(input)` is protected from removal")
                    return
                }

                if let goal = self.goals.removeValue(forKey: input) {
                    output.append(":x: Removed goal `\(input)` (on: \(outputDateFormatter.string(from: goal.date)))")
                } else {
                    output.append(errorText: ":question: No goal named `\(input)` is currently running")
                }
            }
        ]
        info.helpText = makeHelpText()
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        if let date = parseDate(from: input) {
            show("Anonymous Event", as: FixedCountdownGoal(date: date), to: output)
        } else if let parsedArgs = subcommandPattern.firstGroups(in: input) {
            let subcommandName = parsedArgs[1]
            let subcommandArgs = parsedArgs[2]

            guard let subcommand = subcommands[subcommandName] else {
                output.append(errorText: "Could not find subcommand with name \(subcommandName)")
                return
            }

            subcommand(subcommandArgs, output)
        } else {
            removeCompletedGoals() // Clean up
            showRunningGoals(to: output)
        }
    }
    
    private func parseDate(from input: String) -> Date? {
        return inputDateFormatters.compactMap { $0.date(from: input) }.first
    }
    
    private func show(_ name: String, as goal: CountdownGoal, to output: CommandOutput) {
        output.append(.embed(DiscordEmbed(
            title: ":hourglass: \(name) Countdown",
            description: "The next \(name) will take place in **\(describeRemainingTimeUntil(goal: goal))**",
            footer: DiscordEmbed.Footer(text: outputDateFormatter.string(from: goal.date))
        )))
    }
    
    private func showRunningGoals(to output: CommandOutput) {
        output.append(.embed(DiscordEmbed(
            title: ":hourglass: Running Countdowns",
            fields: goals.map { DiscordEmbed.Field(name: $0.key, value: "will take place in **\(describeRemainingTimeUntil(goal: $0.value))** (on \(outputDateFormatter.string(from: $0.value.date)))") }
        )))
    }
    
    private func describeRemainingTimeUntil(goal: CountdownGoal) -> String {
        let date = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: goal.date)
        let days = date.day!
        let hours = date.hour!
        let minutes = date.minute!

        return "\(days) \("day".pluralize(with: days)), \(hours) \("hour".pluralize(with: hours)) and \(minutes) \("minute".pluralize(with: minutes))"
    }
    
    private func removeCompletedGoals() {
        goals = goals.filter { !$0.value.removeAfterCompletion || !$0.value.hasCompleted }
    }
    
    private func makeHelpText() -> String {
        return "Available subcommands: \(subcommands.keys)"
    }
}
