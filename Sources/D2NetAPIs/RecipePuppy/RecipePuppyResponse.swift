public struct RecipePuppyResponse: Sendable, Codable {
    public let title: String
    public let version: Double
    public let href: String
    public let results: [RecipeResult]

    public struct RecipeResult: Sendable, Codable {
        public let title: String
        public let href: String
        public let ingredients: String
        public let thumbnail: String

        public var ingredientList: [String] { ingredients.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } }
    }
}
