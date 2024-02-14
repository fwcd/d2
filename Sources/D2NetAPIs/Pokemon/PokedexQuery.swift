import Utils

public struct PokedexQuery {
    private static var cached: Pokedex? = nil
    private let limit: Int

    public init(limit: Int = 1000) {
        self.limit = limit
    }

    public func perform() -> Promise<Pokedex, any Error> {
        if let pokedex = PokedexQuery.cached {
            return Promise(.success(pokedex))
        } else {
            return Promise.catchingThen {
                try HTTPRequest(host: "pokeapi.co", path: "/api/v2/pokemon", query: ["limit": String(limit)]).fetchJSONAsync(as: Pokedex.self)
            }.peekListen {
                if case let .success(pokedex) = $0 {
                    PokedexQuery.cached = pokedex
                }
            }
        }
    }
}
