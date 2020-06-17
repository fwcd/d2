import Foundation
import D2Utils
import D2MessageIO
import Dispatch

fileprivate let argsPattern = try! Regex(from: "(?:(\\w+)\\s+)?(.+)")
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
}

public class TimerCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Pings a group of users after the timer elapses",
        helpText: """
            Syntax: `[name]? [[number] [s|m|h]]+ [--here]? [--everyone]?`
            ...or alternatively: `[subcommand] [name]`
            
            Examples:
            - Creation: `timer 4s`, `timer 1m 1s`, `timer myTimer 5m`
            - Cancellation: `timer cancel myTimer`
            - Showing all running timers on this guild: `timer list`

            Note that only named timers can be cancelled!
            """,
        requiredPermissionLevel: .vip
    )
    private var timers: [Int: NamedTimer] = [:]
    private var nextTimerId: Int = 0

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let parsedArgs = argsPattern.firstGroups(in: input) else {
            output.append(errorText: info.helpText!)
            return
        }

        let name = parsedArgs[1].nilIfEmpty
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
        timers[timerId] = NamedTimer(name: name, guildId: guildId, timer: timer)

        output.append("Created a timer\(name.map { " named `\($0)`" } ?? "") that runs for \(duration) \("second".pluralize(with: duration))!")
        timer.resume()
    }
}
