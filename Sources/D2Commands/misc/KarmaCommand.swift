import D2MessageIO
import D2Utils

public class KarmaCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches the number of upvote reactions",
        helpText: "Syntax: [users...]?",
        requiredPermissionLevel: .basic
    )
    private let messageDB: MessageDatabase

    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            guard let guild = context.guild else {
                output.append(errorText: "No guild available")
                return
            }
            let users: [User] = context.message.mentions.nilIfEmpty ?? guild.members.map { $0.1.user }
            let emojiName = "upvote"
            let emojiId = try messageDB.emojiIds(for: emojiName).first
            output.append(Embed(
                title: "\(emojiId.map { "<:\(emojiName):\($0)> " } ?? "")Upvote Karma",
                description: try users
                    .map { (try messageDB.countReactions(authorId: $0.id, emojiName: emojiName), $0.username) }
                    .filter { $0.0 > 0 }
                    .sorted(by: descendingComparator { $0.0 })
                    .map { "**\($0.1)**: \($0.0) \("upvote".pluralize(with: $0.0))" }
                    .prefix(20)
                    .joined(separator: "\n")
                    .nilIfEmpty
            ))
        } catch {
            output.append(error, errorText: "Something went wrong while querying the message db")
        }
    }
}