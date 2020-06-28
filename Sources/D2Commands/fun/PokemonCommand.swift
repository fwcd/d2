import Logging
import Foundation
import D2MessageIO
import D2NetAPIs

fileprivate let log = Logger(label: "D2Commands.PokemonCommand")
fileprivate let inventoryCategory = "Pokemon"

public class PokemonCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Catches a random Pokémon",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed
    private let inventoryManager: InventoryManager
    
    public init(inventoryManager: InventoryManager) {
        self.inventoryManager = inventoryManager
    }
    
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
                    self.addToInventory(pokemon: pokemon, context: context)
                case .failure(let error):
                    output.append(error, errorText: "Could not fetch Pokédex.")
            }
        }
    }
    
    private func addToInventory(pokemon: PokedexEntry, context: CommandContext) {
        guard let author = context.author else {
            log.warning("Could not add to inventory since no author is present")
            return
        }
        var inventory = inventoryManager[author]
        inventory.append(item: .init(fromPokemon: pokemon), to: inventoryCategory)
        inventoryManager[author] = inventory
    }
}
