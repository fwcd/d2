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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: info.helpText!)
            return
        }
        do {
            let dex = try await PokedexQuery().perform()
            guard let stub = dex.results.min(by: ascendingComparator(comparing: { $0.name.levenshteinDistance(to: input, caseSensitive: false) })) else { throw PokedexError.couldNotFindPokemon(input) }
            let pokemon = try await PokemonQuery(url: stub.url).perform()
            let fields: [(String, String?)] = [
                ("Base Experience", pokemon.baseExperience.map { String($0) }),
                ("Weight", pokemon.weight.map { String($0) }),
                ("Order", pokemon.order.map { String($0) }),
                ("Abilities", pokemon.abilities.flatMap { $0.map(\.ability.name).joined(separator: ", ").nilIfEmpty }),
                ("Forms", pokemon.forms.flatMap { $0.map(\.name).joined(separator: ", ").nilIfEmpty }),
                ("Stats", pokemon.stats.flatMap { $0.map { "\($0.stat.name): base \($0.baseStat), effort \($0.effort)" }.joined(separator: "\n").nilIfEmpty })
            ]

            await output.append(Embed(
                title: pokemon.name.withFirstUppercased,
                thumbnail: (pokemon.sprites?.url).map(Embed.Thumbnail.init(url:)),
                fields: fields.compactMap { (k, v) in v.map { Embed.Field(name: k, value: $0, inline: true) } }
            ))
        } catch {
            await output.append(error, errorText: "Could not find Pokémon.")
        }
    }
}
