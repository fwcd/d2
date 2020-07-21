import Foundation
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

            let date30DaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())
            let countPerField = 8
            output.append(Embed(
                title: "Emoji Usage in Messages",
                fields: try [("all time", nil), ("last 30 days", date30DaysAgo)]
                    .map { ($0.0, try messageDB.queryMostUsedEmojis(on: guildId, minTimestamp: $0.1)) }
                    .flatMap { [
                        Embed.Field(name: "Most used (\($0.0))", value: format(emojis: Array($0.1.prefix(countPerField))).nilIfEmpty ?? "_none_", inline: true),
                        Embed.Field(name: "Least used (\($0.0))", value: format(emojis: Array($0.1.reversed().prefix(countPerField))).nilIfEmpty ?? "_none_", inline: true),
                    ] }
            ))
        } catch {
            output.append(error, errorText: "Could not lookup most used emojis")
        }
    }

    private func format(emojis: [(emojiName: String, emojiId: Int64, count: Int)]) -> String {
        emojis
            .map { "<:\($0.emojiName):\($0.emojiId)> was used \($0.count) \("time".pluralize(with: $0.count))" }
            .joined(separator: "\n")
    }
}
