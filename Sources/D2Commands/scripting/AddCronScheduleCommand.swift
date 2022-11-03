import Utils
import D2MessageIO

fileprivate let argsPattern = try! Regex(from: "([\\*\\s\\-/,]*)\\s+(\\w+)\\s+(.+)")

public class AddCronScheduleCommand: StringCommand {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Adds a cron schedule",
        helpText: """
            Syntax: [cron schedule] [schedule name] [command]

            Registers a cron-schedule to execute the given (raw) command repeatedly.
            Note that pipes are not supported currently.
            """,
        requiredPermissionLevel: .admin
    )
    private let cronManager: CronManager

    public init(cronManager: CronManager) {
        self.cronManager = cronManager
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard let parsedArgs = argsPattern.firstGroups(in: input) else {
            output.append(errorText: info.helpText!)
            return
        }
        guard let channelId = context.channel?.id else {
            output.append(errorText: "No channel id")
            return
        }

        let cron = parsedArgs[1]
        let name = parsedArgs[2]
        let command = parsedArgs[3]

        guard cronManager[name] == nil else {
            output.append(errorText: "Schedule with name `\(name)` already exists, please unregister it first!")
            return
        }

        cronManager[name] = CronTab.Schedule(
            cron: cron,
            command: command,
            channelId: channelId
        )
        output.append("Added cron schedule listener!")
    }
}
