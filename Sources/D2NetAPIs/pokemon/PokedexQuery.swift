import D2Utils

public struct PokedexQuery {
    private static var cached: [PokedexEntry]? = nil

    public init() {}

    public func perform() -> Promise<[PokedexEntry], Error> {
        if let pokedex = PokedexQuery.cached {
            return Promise(.success(pokedex))
        } else {
            return Promise.catchingThen {
                try HTTPRequest(host: "randompokemon.com", path: "/dex/all.json").fetchJSONAsync(as: [PokedexEntry].self)
            }.peekListen {
                PokedexQuery.cached = $0
            }
        }
    }
}
