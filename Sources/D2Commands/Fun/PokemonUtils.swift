import D2NetAPIs

extension Inventory.Item {
    init(fromPokemon pokemon: Pokemon) {
        self.init(
            id: String(pokemon.id),
            name: pokemon.name,
            iconUrl: pokemon.sprites?.url
        )
    }
}
