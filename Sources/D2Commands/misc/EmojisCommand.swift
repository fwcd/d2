import D2MessageIO
import D2Utils

public class EmojisCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches/searches the current guild's custom emojis",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let guild = context.guild else {
            output.append(errorText: "Not on a guild")
            return
        }

        let emojis = guild.emojis.values.filter { !$0.animated && (input.isEmpty || $0.name.lowercased().contains(input.lowercased())) }
        var groups = [String: Set<Emoji>]()

        for emoji in emojis {
            for hump in emoji.name.camelHumpsWithUnderscores {
                groups[hump.withFirstUppercased] = (groups[hump.withFirstUppercased] ?? []).union([emoji])
            }
        }

        let emojiLimit = 50
        var orderedGroups = [(String, Set<Emoji>)]()
        var insertedEmoji = Set<Emoji>()

        for (name, emojis) in groups.sorted(by: descendingComparator(comparing: { $0.1.count }, then: { $0.0 })) {
            let remaining = emojis.subtracting(insertedEmoji)
            orderedGroups.append((name, remaining))
            insertedEmoji.formUnion(emojis)

            if insertedEmoji.count > emojiLimit {
                break
            }
        }

        output.append(Embed(
            title: "Emojis",
            fields: orderedGroups
                .map { ("\($0.0.truncate(10, appending: "..."))", value: $0.1.map { "<:\($0.name):\($0.id.map { "\($0)" } ?? "?")>" }.truncate(10, appending: "...").joined().nilIfEmpty) }
                .compactMap { (k, v) in v.map { Embed.Field(name: k, value: $0, inline: true) } }
        ))
    }
}
