import D2MessageIO
import D2Utils

public class EmojisCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches/searches the current guild's custom emojis",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed

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
        let comparator: ((String, Set<Emoji>), (String, Set<Emoji>)) -> Bool = descendingComparator(comparing: { $0.1.count }, then: { $0.0 })
        var orderedGroups = [(String, Set<Emoji>)]()
        var insertedEmoji = Set<Emoji>()

        for (name, emojis) in groups.sorted(by: comparator) {
            let remaining = emojis.subtracting(insertedEmoji)
            orderedGroups.append((name, remaining))
            insertedEmoji.formUnion(emojis)
        }

        orderedGroups.sort(by: comparator)

        output.append(Embed(
            title: "Emojis",
            fields: orderedGroups
                .reduce([(String, Set<Emoji>)]()) {
                    var res = $0
                    res.append($1)
                    return res.count <= emojiLimit ? res : $0
                }
                .map { ("\($0.0.truncate(10, appending: "..."))", value: $0.1.map { "<:\($0.name):\($0.id.map { "\($0)" } ?? "?")>" }.truncate(10, appending: "...").joined().nilIfEmpty) }
                .compactMap { (k, v) in v.map { Embed.Field(name: k, value: $0, inline: true) } }
        ))
    }
}
