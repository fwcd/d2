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
                Embed.Field(name: "\($0.key.withFirstUppercased)", value: $0.value.map { "<:\($0.name):\($0.id.map { "\($0)" } ?? "?")>" }.truncate(20, appending: "...").joined())
            }
        ))
    }

    private func group(_ emojis: [Emoji], withMinPerGroup minPerGroup: Int, by mappers: [(Emoji) -> String]) -> [(key: String, value: [Emoji])] {
        guard let mapper = mappers.first else { return [("Others", emojis)] }
        let (groups, rest) = Dictionary(grouping: emojis, by: mapper)
            .sorted(by: descendingComparator { $0.1.count })
            .span { $0.1.count >= minPerGroup }
        var allGroups = Array(groups)
        if !rest.isEmpty {
            allGroups = merge(allGroups, group(rest.flatMap { $0.1 }, withMinPerGroup: minPerGroup, by: Array(mappers.dropFirst())))
        }
        return allGroups
    }

    private func merge<T, U>(_ lhs: [(T, [U])], _ rhs: [(T, [U])]) -> [(T, [U])] where T: Equatable {
        var result = lhs
        for (key, values) in rhs {
            var found = false
            for i in 0..<lhs.count {
                if result[i].0 == key {
                    result[i].1 += values
                    found = true
                }
            }
            if !found {
                result.append((key, values))
            }
        }
        return result
    }
}
