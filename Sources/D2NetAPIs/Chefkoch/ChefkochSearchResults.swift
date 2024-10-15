public struct ChefkochSearchResults: Sendable, Codable {
    public let count: Int
    public let results: [ScoredResult]

    public struct ScoredResult: Sendable, Codable {
        public let score: Double
        public let recipe: ChefkochRecipe
    }
}
