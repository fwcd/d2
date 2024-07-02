import Utils

public struct ChefkochSearchQuery {
    private let query: String
    private let limit: Int
    private let orderBy: OrderBy
    private let descendCategories: Bool
    private let order: Bool

    public init(
        query: String,
        limit: Int = 5,
        orderBy: OrderBy = .relevance,
        descendCategories: Bool = true,
        order: Bool = false
    ) {
        self.query = query
        self.limit = limit
        self.orderBy = orderBy
        self.descendCategories = descendCategories
        self.order = order
    }

    public enum OrderBy: Int {
        case relevance = 2
        case rating = 3
        case difficulty = 4
        case maxTimeNeeded = 5
        case date = 6
        case random = 7
        case dailyShuffle = 8
    }

    public func perform() async throws -> ChefkochSearchResults {
        let request = try HTTPRequest(
            host: "api.chefkoch.de",
            path: "/v2/recipes",
            query: [
                "query": query,
                "limit": String(limit),
                "orderBy": String(orderBy.rawValue),
                "descendCategories": descendCategories ? "1" : "0",
                "order": order ? "1" : "0",
            ]
        )
        return try await request.fetchJSON(as: ChefkochSearchResults.self)
    }
}
