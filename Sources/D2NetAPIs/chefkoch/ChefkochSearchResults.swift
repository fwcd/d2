public struct ChefkochSearchResults: Codable {
    public let count: Int
    public let results: [ScoredResult]

    public struct ScoredResult: Codable {
        public let score: Double
        public let recipe: ChefkochRecipe
    }
}
