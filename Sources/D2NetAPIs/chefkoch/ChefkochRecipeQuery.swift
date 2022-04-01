import Utils

public struct ChefkochRecipeQuery {
    public let id: String

    public init(id: String) {
        self.id = id
    }

    public func perform() -> Promise<ChefkochRecipe, any Error> {
        Promise.catching { try HTTPRequest(host: "api.chefkoch.de", path: "/v2/recipes/\(id)") }
            .then { $0.fetchJSONAsync(as: ChefkochRecipe.self) }
    }
}
