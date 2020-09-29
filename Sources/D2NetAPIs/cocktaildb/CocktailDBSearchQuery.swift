import Utils

public struct CocktailDBSearchQuery {
    private let term: String

    public init(term: String) {
        self.term = term
    }

    public func perform() -> Promise<CocktailDBResults, Error> {
        Promise.catching { try HTTPRequest(host: "www.thecocktaildb.com", path: "/api/json/v1/1/search.php", query: ["s": term]) }
            .then { $0.fetchJSONAsync(as: CocktailDBResults.self) }
    }
}
