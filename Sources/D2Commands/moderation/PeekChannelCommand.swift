import D2MessageIO
import Utils

fileprivate let idPattern = try! Regex(from: "\\d+")

public class PeekChannelCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Peeks a channel's most recent messages",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let client = context.client else {
            output.append(errorText: "No client available!")
            return
        }

        let parsedId: ChannelID?

        if input.isEmpty {
            parsedId = context.channel?.id
        } else {
            parsedId = idPattern.firstGroups(in: input)?.first.map { ChannelID($0, clientName: client.name) }
        }

        guard let channelId = parsedId else {
            output.append(errorText: "Could not parse ID")
            return
        }

        client.getMessages(for: channelId, limit: 10).listen {
            do {
                let messages = try $0.get()
                output.append(Embed(
                    title: ":roll_of_paper: Most Recent Messages",
                    description: messages
                        .map { "[\($0.timestamp.map { "\($0)" } ?? "?")] \($0.author?.username ?? "<unnamed>"): \($0.content.truncated(to: 200, appending: "..."))" }
                        .joined(separator: "\n")
                ))
            } catch {
                output.append(error, errorText: "Could not fetch channel's messages")
            }
        }
    }
}
