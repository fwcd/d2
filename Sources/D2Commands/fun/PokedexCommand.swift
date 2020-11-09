import D2MessageIO
import Utils
import D2NetAPIs

public class PokedexCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Queries the Pokedex",
        helpText: "Syntax: [name]",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: info.helpText!)
            return
        }
        PokedexQuery().perform().listen {
            do {
                let pokedex = try $0.get()
                guard let pokemon = pokedex.min(by: ascendingComparator(comparing: { $0.name.levenshteinDistance(to: input, caseSensitive: false) ?? Int.max })) else {
                    output.append(errorText: "No such Pokémon could be found.")
                    return
                }
                output.append(Embed(
                    title: pokemon.name,
                    thumbnail: (pokemon.sprites?.url).map(Embed.Thumbnail.init(url:)),
                    fields: [
                        ("Base Experience", pokemon.baseExperience.map { String($0) }),
                        ("Weight", pokemon.weight.map { String($0) }),
                        ("Order", pokemon.order.map { String($0) }),
                        ("Abilities", pokemon.abilities.flatMap { $0.map(\.abilitiy.name).joined(separator: ", ").nilIfEmpty })
                        ("Forms", pokemon.forms.flatMap { $0.map(\.name).joined(separator: ", ").nilIfEmpty }),
                        ("Stats", pokemon.stats.flatMap { $0.map { "\($0.stat.name): Base \($0.stat.baseStat), effort \($0.stat.effort)" }.joined(separator: ", ").nilIfEmpty })
                    ].compactMap { (k, v) in v.map { Embed.Field(name: k, value: $0) } }
                ))
            } catch {
                output.append(error, errorText: "Could not fetch Pokédex.")
            }
        }
    }
}
