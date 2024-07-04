import D2MessageIO
import Utils

public class ThreadsCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Lists active threads in this channel",
        requiredPermissionLevel: .vip
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let channelId = context.channel?.id else {
            await output.append(errorText: "No channel id available.")
            return
        }
        guard let guild = context.guild else {
            await output.append(errorText: "No guild available.")
            return
        }
        let threads = guild.threads.values
            .filter { $0.parentId == channelId }
            .sorted(by: ascendingComparator(comparing: \.position))

        await output.append(Embed(
            title: ":thread: Active Threads",
            description: threads.map { "<#\($0.id)>" }.joined(separator: "\n")
        ))
    }
}
