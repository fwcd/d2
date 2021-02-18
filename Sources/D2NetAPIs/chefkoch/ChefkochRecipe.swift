import Foundation

public struct ChefkochRecipe: Codable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let owner: User?
    public let editor: User?
    public let rating: Rating?
    public let difficulty: Double?
    public let hasImage: Bool?
    public let hasVideo: Bool?
    public let isSubmitted: Bool?
    public let isRejected: Bool?
    public let previewImageId: String?
    public let siteUrl: URL?

    // Full recipe snippet (only through ChefkochRecipeQuery)

    public let instructions: String?
    public let miscellaneousText: String?
    public let ingredientsText: String?
    public let tags: [String]?
    public let viewCount: Int?
    public let cookingTime: Double?
    public let restingTime: Double?
    public let totalTime: Double?
    public let ingredientGroups: [IngredientGroup]?

    public struct User: Codable {
        public let id: String
        public let username: String
        public let hasAvatar: Bool?
        public let hasPaid: Bool?
    }

    public struct Rating: Codable {
        public let rating: Double?
        public let numVotes: Int?
    }

    public struct IngredientGroup: Codable {
        public let header: String?
        public let ingredients: [Ingredient]

        public struct Ingredient: Codable {
            public let id: String
            public let name: String
            public let unit: String
            public let unitId: String?
            public let amount: Double
            public let productGroup: String?
            public let isBasic: Bool?
            public let usageInfo: String?
            public let foodId: String?
            public let url: URL?
        }
    }
}
