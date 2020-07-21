import D2MessageIO

public class EmojiUsageCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Lists the most used emojis on the guild",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed
    private let messageDB: MessageDatabase

    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            guard let guildId = context.guild?.id else {
                output.append(errorText: "Not on a guild!")
                return
            }

            let emojis = try messageDB.queryMostUsedEmojis(on: guildId, limit: 20)
            output.append(Embed(
                title: "Most used Emojis in Messages",
                description: emojis
                    .map { "<:\($0.emojiName):\($0.emojiId)> was used \($0.count) \("time".pluralize(with: $0.count))" }
                    .joined(separator: "\n")
            ))
        } catch {
            output.append(error, errorText: "Could not lookup most used emojis")
        }
    }
}
