public struct RecipePuppyResponse: Codable {
    private let title: String
    private let version: Double
    private let href: String
    private let results: [RecipeResult]

    public struct RecipeResult: Codable {
        public let title: String
        public let href: String
        public let ingredients: String
        public let thumbnail: String

        public var ingredientList: [String] { ingredients.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } }
    }
}
