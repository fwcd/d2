import Utils

public struct ChefkochRecipeQuery: Sendable {
    public let id: String

    public init(id: String) {
        self.id = id
    }

    public func perform() async throws -> ChefkochRecipe {
        let request = try HTTPRequest(host: "api.chefkoch.de", path: "/v2/recipes/\(id)")
        return try await request.fetchJSON(as: ChefkochRecipe.self)
    }
}
