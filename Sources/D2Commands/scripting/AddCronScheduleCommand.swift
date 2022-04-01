import Utils
import D2MessageIO

fileprivate let argsPattern = try! Regex(from: "([\\*\\s\\-/,]*)\\s+(\\w+)")

public class AddCronScheduleCommand: StringCommand {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Adds a cron schedule",
        helpText: """
            Syntax: [cron schedule] [cron]

            Registers a cron-schedule to execute the piped command repeatedly.
            """,
        requiredPermissionLevel: .admin
    )
    private let cronSchedulerBus: CronSchedulerBus

    public init(cronSchedulerBus: CronSchedulerBus) {
        self.cronSchedulerBus = cronSchedulerBus
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        if let parsedArgs = argsPattern.firstGroups(in: input) {
            let cron = parsedArgs[1]
            let name = parsedArgs[2]

            do {
                try cronSchedulerBus.addSchedule(name: name, with: cron, output: output)
                context.channel?.send(Message(content: "Added cron schedule listener!"))
            } catch {
                output.append(error, errorText: "Could not add cron schedule (invalid syntax?)")
            }
        } else {
            output.append(errorText: info.helpText!)
        }
    }
}
