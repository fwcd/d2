import Utils

public struct RecipePuppyQuery: Sendable {
    private let ingredients: [String]?
    private let term: String
    private let page: Int

    public init(
        ingredients: [String]? = nil,
        term: String,
        page: Int = 1
    ) {
        self.ingredients = ingredients
        self.term = term
        self.page = page
    }

    public func perform() async throws -> RecipePuppyResponse {
        let request = try HTTPRequest(
            scheme: "http",
            host: "www.recipepuppy.com",
            path: "/api",
            query: ["q": term, "p": String(page)]
                .merging(ingredients.map { ["i": $0.joined(separator: ",")] } ?? [:], uniquingKeysWith: { k, _ in k })
        )
        return try await request.fetchJSON(as: RecipePuppyResponse.self)
    }
}
