import Utils

public struct ChefkochImageQuery {
    public let recipeId: String
    public let imageId: String

    public init(recipeId: String, imageId: String) {
        self.recipeId = recipeId
        self.imageId = imageId
    }

    public func perform() -> Promise<ChefkochImage, any Error> {
        Promise.catching { try HTTPRequest(host: "api.chefkoch.de", path: "/v2/recipes/\(recipeId)/images/\(imageId)") }
            .then { $0.fetchJSONAsync(as: ChefkochImage.self) }
    }
}
