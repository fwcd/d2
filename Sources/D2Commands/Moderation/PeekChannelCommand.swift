import D2MessageIO
import Utils

nonisolated(unsafe) private let idPattern = #/\d+/#

public class PeekChannelCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Peeks a channel's most recent messages",
        requiredPermissionLevel: .admin
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let sink = context.sink else {
            await output.append(errorText: "No client available!")
            return
        }

        let parsedId: ChannelID?

        if input.isEmpty {
            parsedId = context.channel?.id
        } else {
            parsedId = (try? idPattern.firstMatch(in: input))?.first.map { ChannelID(String($0), clientName: sink.name) }
        }

        guard let channelId = parsedId else {
            await output.append(errorText: "Could not parse ID")
            return
        }

        do {
            let messages = try await sink.getMessages(for: channelId, limit: 20)
            await output.append(Embed(
                title: ":roll_of_paper: Most Recent Messages",
                description: messages
                    .compactMap { m in m.timestamp.map { ($0, m) } }
                    .sorted(by: ascendingComparator(comparing: \.0))
                    .map { "[\($0.0)] `\($0.1.author?.username ?? "<unnamed>")`: \($0.1.content.truncated(to: 100, appending: "..."))" }
                    .joined(separator: "\n")
            ))
        } catch {
            await output.append(error, errorText: "Could not fetch channel's messages")
        }
    }
}
