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

        let emojis = guild.emojis.values.filter { !$0.animated }
        let groups = group(emojis, withMinPerGroup: 2, by: [
            { $0.name.camelHumpsWithUnderscores.first ?? "" },
            { $0.name.camelHumpsWithUnderscores.last ?? "" }
        ])

        output.append(Embed(
            title: "Emojis",
            fields: groups.map {
                Embed.Field(name: "\($0.key.withFirstUppercased)", value: $0.value.map { "<:\($0.name):\($0.id.map { "\($0)" } ?? "?")>" }.truncate(20, appending: "...").joined(), inline: true)
            }
        ))
    }

    private func group(_ emojis: [Emoji], withMinPerGroup minPerGroup: Int, by mappers: [(Emoji) -> String]) -> [(key: String, value: Set<Emoji>)] {
        let (groups, rest) = mappers
            .map { Dictionary(grouping: emojis, by: $0).mapValues(Set.init) }
            .reduce([:], merge)
            .map { ($0.0, Set($0.1)) }
            .sorted(by: descendingComparator { $0.1.count })
            .span { $0.1.count >= minPerGroup }
        return Array(groups + rest)
    }

    private func merge<T, U>(_ lhs: [T: Set<U>], _ rhs: [T: Set<U>]) -> [T: Set<U>] where T: Hashable, U: Hashable {
        var result = lhs
        for (key, values) in rhs {
            result[key] = (result[key] ?? []).union(values)
        }
        return result
    }
}
