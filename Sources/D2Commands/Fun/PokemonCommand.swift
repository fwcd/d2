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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        PokedexQuery().perform()
            .map { $0.results[Int.random(in: 0..<$0.results.count)] }
            .then { PokemonQuery(url: $0.url).perform() }
            .listen {
                do {
                    let pokemon = try $0.get()
                    let author = context.author?.username ?? "You"
                    output.append(Embed(
                        title: "**\(author)**, you've caught a **\(pokemon.name)**",
                        image: (pokemon.sprites?.url).map(Embed.Image.init(url:))
                    ))
                    self.addToInventory(pokemon: pokemon, context: context)
                } catch {
                    output.append(error, errorText: "Could not fetch Pokémon.")
                }
            }
    }

    private func addToInventory(pokemon: Pokemon, context: CommandContext) {
        guard let author = context.author else {
            log.warning("Could not add to inventory since no author is present")
            return
        }
        var inventory = inventoryManager[author]
        inventory.append(item: .init(fromPokemon: pokemon), to: inventoryCategory)
        inventoryManager[author] = inventory
    }
}
