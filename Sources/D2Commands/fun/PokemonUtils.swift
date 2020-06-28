import D2NetAPIs

extension Inventory.Item {
    init(fromPokemon pokemon: PokedexEntry) {
        self.init(
            id: String(pokemon.id),
            name: pokemon.name ?? "Anonymous Pokemon",
            iconUrl: pokemon.gifUrl
        )
    }
}
