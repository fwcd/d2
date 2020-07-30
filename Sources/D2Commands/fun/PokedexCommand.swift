import D2MessageIO
import D2Utils
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

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: info.helpText!)
            return
        }
        PokedexQuery().perform().listen {
            switch $0 {
                case .success(let pokedex):
                    guard let pokemon = pokedex.min(by: ascendingComparator(comparing: { $0.name?.levenshteinDistance(to: input, caseSensitive: false) ?? Int.max })) else {
                        output.append(errorText: "No such Pokémon could be found.")
                        return
                    }
                    output.append(Embed(
                        title: pokemon.name ?? "Unnamed Pokémon",
                        thumbnail: Embed.Thumbnail(url: pokemon.gifUrl),
                        fields: [
                            Embed.Field(name: "Types", value: pokemon.types?.joined(separator: ", ").nilIfEmpty ?? "_none_"),
                            Embed.Field(name: "Forms", value: pokemon.forms?.compactMap { $0.name }.joined(separator: ", ").nilIfEmpty ?? "_none_")
                        ]
                    ))
                case .failure(let error):
                    output.append(error, errorText: "Could not fetch Pokédex.")
            }
        }
    }
}
