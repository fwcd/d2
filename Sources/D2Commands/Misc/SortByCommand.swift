import D2MessageIO
import D2Permissions
import Utils

// TODO: Use Arg API

public class SortByCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches the top messages by a certain criterion",
        longDescription: "Queries the current channel for messages matching the given criterion and returns the top n from this list",
        helpText: "Syntax: sortby [criterion]",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed

    private let sortCriteria: [String: (Message, Message) -> Bool] = [
        "length": descendingComparator { $0.content.count },
        "upvotes": descendingComparator { $0.reactions.first { $0.emoji.name == "upvote" }?.count ?? -1000 }
    ]

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let criterion = sortCriteria[input] else {
            await output.append(errorText: "Unrecognized sort criterion: \(input). Try using one of these: \(sortCriteria.keys)")
            return
        }
        guard let channel = context.channel?.id else {
            await output.append(errorText: "No channel found for message")
            return
        }

        do {
            let messages = try await context.sink?.getMessages(for: channel, limit: 80) ?? []
            let sorted = messages.sorted(by: criterion)
            await output.append(Embed(
                title: ":star: Top messages",
                fields: Array(sorted
                    .map { Embed.Field(name: $0.author?.username ?? "Unknown Author", value: $0.content.nilIfEmpty ?? "No content") }
                    .prefix(10))
            ))
        } catch {
            await output.append(error, errorText: "Could not get messages")
        }
    }
}
