import Utils

public struct CocktailDBSearchQuery {
    private let term: String

    public init(term: String) {
        self.term = term
    }

    public func perform() async throws -> CocktailDBResults {
        let request = try HTTPRequest(host: "www.thecocktaildb.com", path: "/api/json/v1/1/search.php", query: ["s": term])
        return try await request.fetchJSON(as: CocktailDBResults.self)
    }
}
