public struct CocktailDBResults: Codable {
    public let drinks: [Drink]

    public struct Drink: Codable {
        public let idDrink: String
        public let strDrink: String?
        public let strDrinkAlternate: String?
        public let strDrinkES: String?
        public let strDrinkDE: String?
        public let strDrinkFR: String?
        public let strTags: String?
        public let strVideo: String?
        public let strCategory: String?
        public let strIBA: String?
        public let strAlcoholic: String?
        public let strGlass: String?
        public let strInstructions: String?
        public let strInstructionsES: String?
        public let strInstructionsDE: String?
        public let strInstructionsFR: String?
        public let strDrinkThumb: String?
        public let strIngredient1: String?
        public let strIngredient2: String?
        public let strIngredient3: String?
        public let strIngredient4: String?
        public let strIngredient5: String?
        public let strIngredient6: String?
        public let strIngredient7: String?
        public let strIngredient8: String?
        public let strIngredient9: String?
        public let strIngredient10: String?
        public let strIngredient11: String?
        public let strIngredient12: String?
        public let strIngredient13: String?
        public let strIngredient14: String?
        public let strIngredient15: String?
        public let strMeasure1: String?
        public let strMeasure2: String?
        public let strMeasure3: String?
        public let strMeasure4: String?
        public let strMeasure5: String?
        public let strMeasure6: String?
        public let strMeasure7: String?
        public let strMeasure8: String?
        public let strMeasure9: String?
        public let strMeasure10: String?
        public let strMeasure11: String?
        public let strMeasure12: String?
        public let strMeasure13: String?
        public let strMeasure14: String?
        public let strMeasure15: String?
        public let strCreativeCommonsConfirmed: String?
        public let dateModified: String?

        public var tags: [String] { strTags?.split(separator: " ").map(String.init) ?? [] }
        public var ingredients: [String] {
            [strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5, strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10, strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15]
                .compactMap { $0 }
        }
        public var measures: [String] {
            [strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5, strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10, strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15]
                .compactMap { $0 }
        }
    }
}
