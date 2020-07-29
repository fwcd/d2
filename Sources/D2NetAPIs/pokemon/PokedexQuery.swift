import D2Utils

public struct PokedexQuery {
    private static var cached: [PokedexEntry]? = nil

    public init() {}

    public func perform() -> Promise<[PokedexEntry], Error> {
        if let pokedex = PokedexQuery.cached {
            then(.success(pokedex))
        } else {
            do {
                let request = try HTTPRequest(host: "randompokemon.com", path: "/dex/all.json")
                request.fetchJSONAsync(as: [PokedexEntry].self) {
                    switch $0 {
                        case .success(let pokedex):
                            PokedexQuery.cached = pokedex
                            then(.success(pokedex))
                        case .failure(let error):
                            then(.failure(error))
                    }
                }
            } catch {
                then(.failure(error))
            }
        }
    }
}
