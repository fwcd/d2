import Utils
import D2MessageIO

public class RemoveCronScheduleCommand: StringCommand {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Removes a cron schedule",
        helpText: """
            Syntax: [name]

            Unregisters a cron-scheduled command.
            """,
        requiredPermissionLevel: .admin
    )
    private let cronSchedulerBus: CronSchedulerBus

    public init(cronSchedulerBus: CronSchedulerBus) {
        self.cronSchedulerBus = cronSchedulerBus
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        cronSchedulerBus.removeSchedule(name: input)
        output.append("Removed schedule `\(input)` (if it existed)")
    }
}
