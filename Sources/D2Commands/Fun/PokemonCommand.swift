import Logging
import Foundation
import D2MessageIO
import D2NetAPIs

private let log = Logger(label: "D2Commands.PokemonCommand")
private let inventoryCategory = "Pokemon"

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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let dex = try await PokedexQuery().perform()
            let stub = dex.results.randomElement()!
            let pokemon = try await PokemonQuery(url: stub.url).perform()
            let author = context.author?.username ?? "You"
            await output.append(Embed(
                title: "**\(author)**, you've caught a **\(pokemon.name)**",
                image: (pokemon.sprites?.url).map(Embed.Image.init(url:))
            ))
            self.addToInventory(pokemon: pokemon, context: context)
        } catch {
            await output.append(error, errorText: "Could not fetch Pokémon.")
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
