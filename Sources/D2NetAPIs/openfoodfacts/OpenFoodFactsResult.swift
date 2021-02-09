import Foundation

public struct OpenFoodFactsResult: Codable {
    public let product: Product

    // TODO: Add more product fields, see
    // https://world.openfoodfacts.org/api/v0/product/737628064502.json
    // for an example.

    public struct Product: Codable {
        public enum CodingKeys: String, CodingKey {
            case imageNutritionUrl = "image_nutrition_url"
            case comparedToCategory = "compared_to_category"
            case ingredientsTextWithAllergensEn = "ingredients_text_with_allergens_en"
            case ingredientsTextEn = "ingredients_text_en"
            case genericNameEn = "generic_name_en"
            case genericNameDe = "generic_name_de"
            case genericName = "generic_name"
            case imageThumbUrl = "image_thumb_url"
            case creator
            case brandOwnerImported = "brand_owner_imported"
            case productNameEnImported = "product_name_en_imported"
        }

        public let imageNutritionUrl: URL?
        public let comparedToCategory: String?
        public let ingredientsTextWithAllergensEn: String?
        public let ingredientsTextEn: String?
        public let genericNameEn: String?
        public let genericNameDe: String?
        public let genericName: String?
        public let imageThumbUrl: URL?
        public let creator: String?
        public let brandOwnerImported: String?
        public let productNameEnImported: String?
    }
}
