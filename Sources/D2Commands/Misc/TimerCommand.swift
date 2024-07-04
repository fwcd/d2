import Foundation
import Utils
import D2MessageIO

fileprivate let argsPattern = #/(?:(?<name>[a-zA-Z]+)\s*)?(?<rest>.*)/#
fileprivate let durationPattern = #/(\d+)\s*([a-zA-Z]+)/#
fileprivate let flagPattern = #/--([a-z]+)/#
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
    let task: Task<Void, Never>
    let duration: Int
    let elapseDate: Date

    var remainingTime: TimeInterval { elapseDate.timeIntervalSinceNow }
}

public class TimerCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Pings a group of users after the timer elapses",
        presented: true,
        requiredPermissionLevel: .vip
    )
    private var subcommands: [String: (String, CommandOutput, CommandContext) async -> Void] = [:]
    private var timers: [Int: NamedTimer] = [:]
    private var nextTimerId: Int = 0

    public init() {
        // TODO: Serialize timer elapse timestamps in a JSON file

        subcommands = [
            "list": { [unowned self] input, output, context in
                await output.append(Embed(
                    title: ":timer: Running Timers",
                    description: self.timers.values
                        .filter { $0.guildId == context.guild?.id }
                        .sorted(by: ascendingComparator { $0.remainingTime })
                        .map { "\($0.duration)s timer\($0.name.map { "`\($0)`" } ?? "") elapses in \($0.remainingTime.displayString)" }
                        .joined(separator: "\n")
                ))
            },
            "cancel": { [unowned self] input, output, context in
                guard let (id, timer) = self.timers.first(where: { $0.value.name == input }) else {
                    await output.append(errorText: "No timer named `\(input)`!")
                    return
                }
                timer.task.cancel()
                self.timers[id] = nil
                await output.append("Successfully cancelled timer `\(timer.name ?? "<unnamed>")`!")
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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let parsedArgs = try? argsPattern.firstMatch(in: input) else {
            await output.append(errorText: info.helpText!)
            return
        }

        let name = parsedArgs.name.map { String($0) }

        if let n = name, let subcommand = subcommands[n] {
            // Invoke the subcommand

            await subcommand(String(parsedArgs.rest), output, context)
        } else {
            // Create a new timer

            let rawDurations = parsedArgs.rest
            let allParsedDurations = rawDurations.matches(of: durationPattern)
            let flags = input.matches(of: flagPattern).map { $0.1 }
            let durations = allParsedDurations.compactMap { timeUnits[timeUnitAliases[String($0.2)] ?? String($0.2)]?(Int($0.1)!) }

            guard !durations.isEmpty else {
                await output.append(errorText: info.helpText!)
                return
            }

            let authorId = context.author?.id
            let guildId = context.guild?.id
            let duration = durations.reduce(0, +)

            let timerId = nextTimerId
            nextTimerId += 1

            let task = Task {
                do {
                    try await Task.sleep(for: .seconds(duration))
                    let mention: String
                    if flags.contains("everyone") {
                        mention = "@everyone"
                    } else if flags.contains("here") {
                        mention = "@here"
                    } else {
                        mention = authorId.map { "<@\($0)>" } ?? ""
                    }
                    await output.append("\(mention), your \(duration)s timer\(name.map { " `\($0)`" } ?? "") has elapsed!")
                    self.timers[timerId] = nil
                } catch _ as CancellationError {
                    // Do nothing
                } catch {
                    await output.append(error, errorText: "Error while running timer")
                }
            }
            timers[timerId] = NamedTimer(
                name: name,
                guildId: guildId,
                task: task,
                duration: duration,
                elapseDate: Date() + TimeInterval(duration)
            )
            await output.append("Created a timer\(name.map { " named `\($0)`" } ?? "") that runs for \(duration) \("second".pluralized(with: duration))!")
        }
    }
}
