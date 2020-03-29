import D2Utils

public struct PokedexQuery {
    public init() {}

    public func perform(then: @escaping (Result<[PokedexEntry], Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "randompokemon.com", path: "/dex/all.json")
            request.fetchJSONAsync(as: [PokedexEntry].self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
