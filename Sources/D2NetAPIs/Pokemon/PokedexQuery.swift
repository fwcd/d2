import Utils

public struct PokedexQuery: Sendable {
    private let limit: Int

    @globalActor
    private actor Cache: GlobalActor {
        static let shared = Cache()
        private(set) var pokedex: Pokedex? = nil

        func update(pokedex: Pokedex) {
            self.pokedex = pokedex
        }
    }

    public init(limit: Int = 1000) {
        self.limit = limit
    }

    public func perform() async throws -> Pokedex {
        if let pokedex = await Cache.shared.pokedex {
            return pokedex
        } else {
            let pokedex = try await HTTPRequest(
                host: "pokeapi.co",
                path: "/api/v2/pokemon",
                query: ["limit": String(limit)]
            ).fetchJSON(as: Pokedex.self)
            await Cache.shared.update(pokedex: pokedex)
            return pokedex
        }
    }
}
