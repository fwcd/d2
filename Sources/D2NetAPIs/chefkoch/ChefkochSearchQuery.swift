import Utils

public struct ChefkochSearchQuery {
    public let query: String
    public let limit: Int

    public init(query: String, limit: Int = 5) {
        self.query = query
        self.limit = limit
    }

    public func perform() -> Promise<ChefkochSearchResults, Error> {
        Promise.catching { try HTTPRequest(host: "api.chefkoch.de", path: "/v2/recipes", query: ["query": query, "limit": String(limit)]) }
            .then { $0.fetchJSONAsync(as: ChefkochSearchResults.self) }
    }
}
