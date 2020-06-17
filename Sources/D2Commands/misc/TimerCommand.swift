import Foundation
import D2Utils
import Dispatch

fileprivate let argPattern = try! Regex(from: "(\\d+)\\s*([a-zA-Z]+)")
fileprivate let flagPattern = try! Regex(from: "--[a-z]+")
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

public class TimerCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Pings a group of users after the timer elapses",
        helpText: "Syntax: [[number] [s|m|h]]+ [--here]? [--everyone]?",
        requiredPermissionLevel: .vip
    )
    private var timers: [DispatchSourceTimer] = []

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let allParsedArgs = argPattern.allGroups(in: input)
        let flags = flagPattern.allGroups(in: input).map { $0[1] }
        let durations = allParsedArgs.compactMap { timeUnits[timeUnitAliases[$0[2]] ?? $0[2]]?(Int($0[1])!) }

        guard !durations.isEmpty else {
            output.append(errorText: info.helpText!)
            return
        }

        let authorId = context.author?.id
        let duration = durations.reduce(0, +)

        output.append("Created a timer for \(duration) \("second".pluralize(with: duration))!")
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
            output.append("\(mention), the timer has elapsed!")
        }
        timers.append(timer)
        timer.resume()
    }
}
