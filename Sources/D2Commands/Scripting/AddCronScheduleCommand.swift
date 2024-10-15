import Utils
import D2MessageIO

public class AddCronScheduleCommand: RegexCommand {
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

    public let inputPattern = #/(?<cron>[\*\s\d\-/,]*)\s+(?<name>\w+)\s+(?<command>.+)/#

    private let cronManager: CronManager

    public init(cronManager: CronManager) {
        self.cronManager = cronManager
    }

    public func invoke(with input: Input, output: any CommandOutput, context: CommandContext) async {
        guard let channelId = context.channel?.id else {
            await output.append(errorText: "No channel id")
            return
        }

        let cron = String(input.cron)
        let name = String(input.name)
        let command = String(input.command)

        guard cronManager[name] == nil else {
            await output.append(errorText: "Schedule with name `\(name)` already exists, please unregister it first!")
            return
        }

        cronManager[name] = CronTab.Schedule(
            cron: cron,
            command: command,
            channelId: channelId
        )
        await output.append("Added schedule `\(name)`!")
    }
}
