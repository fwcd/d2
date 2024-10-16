import Foundation
import D2MessageIO
import Utils

public class EmojiUsageCommand: StringCommand {
    public let info = CommandInfo(
        category: .emoji,
        shortDescription: "Lists the most used emojis on the guild",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed
    private let messageDB: MessageDatabase

    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            guard let guild = await context.guild else {
                await output.append(errorText: "Not on a guild!")
                return
            }

            let date30DaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())
            let countPerField = 8

            await output.append(Embed(
                title: "Emoji Usage in Messages and Reactions",
                fields: try [("all time", nil), ("last 30 days", date30DaysAgo)]
                    .map { ($0.0, process(emojis: try messageDB.queryMostUsedEmojis(on: guild.id, minTimestamp: $0.1), on: guild)) }
                    .flatMap { [
                        Embed.Field(name: "Most used (\($0.0))", value: format(emojis: Array($0.1.prefix(countPerField))).nilIfEmpty ?? "_none_", inline: true),
                        Embed.Field(name: "Least used (\($0.0))", value: format(emojis: Array($0.1.reversed().prefix(countPerField))).nilIfEmpty ?? "_none_", inline: true),
                    ] }
            ))
        } catch {
            await output.append(error, errorText: "Could not lookup most used emojis")
        }
    }

    private func process(emojis: [(emoji: Emoji, count: Int)], on guild: Guild) -> [(emoji: Emoji, count: Int)] {
        // Remove all emojis that are no longer present on the server
        // IDs are compared using only their values here since the client name cannot be recovered from the DB
        var result = emojis.filter { (emoji, _) in guild.emojis.contains { $0.key.value == emoji.id?.value } }
        let usedIds = Set(result.compactMap(\.emoji.id?.value))

        // Add unused emojis that did not appear in messages queried by the DB
        result += guild.emojis.filter { !usedIds.contains($0.key.value) }.compactMap { (_, emoji) in (emoji: emoji, count: 0) }

        return result.sorted(by: descendingComparator(comparing: \.count))
    }

    private func format(emojis: [(emoji: Emoji, count: Int)]) -> String {
        emojis
            .compactMap { (emoji, count) in emoji.id.map { "<\(emoji.animated ? "a" : ""):\(emoji.name):\($0)> was used \(count) \("time".pluralized(with: count))" } }
            .joined(separator: "\n")
    }
}
