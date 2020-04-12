import Foundation
import D2MessageIO
import D2NetAPIs

public class PokemonCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Catches a random Pokémon",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        PokedexQuery().perform {
            switch $0 {
                case .success(let pokedex):
                    guard let pokemon = pokedex.randomElement() else {
                        output.append(errorText: "No Pokémon could be found.")
                        return
                    }
                    let author = context.author?.username ?? "You"
                    output.append(Embed(
                        title: "**\(author)**, you've caught a **\(pokemon.name ?? "?")**",
                        image: Embed.Image(url: pokemon.gifUrl)
                    ))
                case .failure(let error):
                    output.append(error, errorText: "Could not fetch Pokédex.")
            }
        }
    }
}
