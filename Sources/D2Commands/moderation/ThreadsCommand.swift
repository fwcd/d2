import D2MessageIO
import Utils

public class ThreadsCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Lists active threads in this channel",
        requiredPermissionLevel: .vip
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let channelId = context.channel?.id else {
            output.append(errorText: "No channel id available.")
            return
        }
        guard let guild = context.guild else {
            output.append(errorText: "No guild available.")
            return
        }
        let threads = guild.threads.values
            .filter { $0.parentId == channelId }
            .sorted(by: ascendingComparator(comparing: \.position))

        output.append(Embed(
            title: ":thread: Active Threads",
            description: threads.map { "<#\($0.id)>" }.joined(separator: "\n")
        ))
    }
}
