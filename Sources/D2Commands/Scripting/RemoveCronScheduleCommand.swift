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
    private let cronManager: CronManager

    public init(cronManager: CronManager) {
        self.cronManager = cronManager
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard cronManager[input] != nil else {
            output.append(errorText: "No schedule with `\(input)` registered!")
            return
        }
        cronManager[input] = nil
        output.append("Removed schedule `\(input)`")
    }
}
