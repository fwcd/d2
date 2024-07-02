import Utils

public struct ChefkochImageQuery {
    public let recipeId: String
    public let imageId: String

    public init(recipeId: String, imageId: String) {
        self.recipeId = recipeId
        self.imageId = imageId
    }

    public func perform() async throws -> ChefkochImage {
        let request = try HTTPRequest(host: "api.chefkoch.de", path: "/v2/recipes/\(recipeId)/images/\(imageId)")
        return try await request.fetchJSON(as: ChefkochImage.self)
    }
}
