import Foundation
import D2Utils
import D2MessageIO
import Dispatch

fileprivate let argsPattern = try! Regex(from: "(?:([a-zA-Z]+)\\s*)?(.*)")
fileprivate let durationPattern = try! Regex(from: "(\\d+)\\s*([a-zA-Z]+)")
fileprivate let flagPattern = try! Regex(from: "--([a-z]+)")
fileprivate let timeUnits: [String: (Int) -> Int] = [
    "d": { $0 * 86400 },
    "h": { $0 * 3600 },
    "m": { $0 * 60 },
    "s": { $0 }
]
fileprivate let timeUnitAliases: [String: String] = [
    "days": "d",
    "hours": "h",
    "minutes": "m",
    "seconds": "s",
    "sec": "s"
]

fileprivate struct NamedTimer {
    let name: String?
    let guildId: GuildID?
    let timer: DispatchSourceTimer
    let elapseDate: Date

    var remainingTime: TimeInterval { elapseDate.timeIntervalSinceNow }
}

public class TimerCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Pings a group of users after the timer elapses",
        requiredPermissionLevel: .vip
    )
    private var subcommands: [String: (String, CommandOutput, CommandContext) -> Void] = [:]
    private var timers: [Int: NamedTimer] = [:]
    private var nextTimerId: Int = 0

    public init() {
        subcommands = [
            "list": { [unowned self] input, output, context in
                output.append(Embed(
                    title: ":timer: Running Timers",
                    description: self.timers.values
                        .filter { $0.guildId == context.guild?.id }
                        .sorted(by: descendingComparator { $0.remainingTime })
                        .map { "`\($0.name ?? "<unnamed>")` elapses in \($0.remainingTime.displayString)" }
                        .joined(separator: "\n")
                ))
            },
            "cancel": { [unowned self] input, output, context in
                guard let (id, timer) = self.timers.first(where: { $0.value.name == input }) else {
                    output.append(errorText: "No timer named `\(input)`!")
                    return
                }
                self.timers[id] = nil
                output.append("Successfully cancelled timer `\(timer.name ?? "<unnamed>")`!")
            }
        ]
        info.helpText = """
            Syntax: `[name]? [[number] [s|m|h]]+ [--here]? [--everyone]?`
            ...or alternatively: `[subcommand] [name]`

            Available Subcommands:
            \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))
            
            Examples:
            - Creation: `timer 4s`, `timer 1m 1s`, `timer myTimer 5m`
            - Cancellation: `timer cancel myTimer`
            - Showing all running timers on this guild: `timer list`

            Note that only named timers can be cancelled!
            """
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let parsedArgs = argsPattern.firstGroups(in: input) else {
            output.append(errorText: info.helpText!)
            return
        }
        print(parsedArgs)
        let name = parsedArgs[1].nilIfEmpty

        if let n = name, let subcommand = subcommands[n] {
            // Invoke the subcommand

            subcommand(parsedArgs[2], output, context)
        } else {
            // Create a new timer

            let rawDurations = parsedArgs[2]
            let allParsedDurations = durationPattern.allGroups(in: rawDurations)
            let flags = flagPattern.allGroups(in: input).map { $0[1] }
            let durations = allParsedDurations.compactMap { timeUnits[timeUnitAliases[$0[2]] ?? $0[2]]?(Int($0[1])!) }

            guard !durations.isEmpty else {
                output.append(errorText: info.helpText!)
                return
            }

            let authorId = context.author?.id
            let guildId = context.guild?.id
            let duration = durations.reduce(0, +)

            let timerId = nextTimerId
            nextTimerId += 1

            let timer = DispatchSource.makeTimerSource()
            timer.schedule(deadline: .now() + .seconds(duration))
            timer.setEventHandler {
                let mention: String
                if flags.contains("everyone") {
                    mention = "@everyone"
                } else if flags.contains("here") {
                    mention = "@here"
                } else {
                    mention = authorId.map { "<@\($0)>" } ?? ""
                }
                output.append("\(mention), the timer\(name.map { " `\($0)`" } ?? "") has elapsed!")
                self.timers[timerId] = nil
            }
            timers[timerId] = NamedTimer(name: name, guildId: guildId, timer: timer, elapseDate: Date() + TimeInterval(duration))

            output.append("Created a timer\(name.map { " named `\($0)`" } ?? "") that runs for \(duration) \("second".pluralize(with: duration))!")
            timer.resume()
        }
    }
}
