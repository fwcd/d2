import Foundation

public struct OpenFoodFactsResult: Codable {
    public let status: Int
    public let code: String?
    public let product: Product

    // TODO: Add more product fields, see
    // https://world.openfoodfacts.org/api/v0/product/737628064502.json
    // for an example.

    public struct Product: Codable {
        public enum CodingKeys: String, CodingKey {
            case imageNutritionUrl = "image_nutrition_url"
            case labelsTags = "labels_tags"
            case productQuantity = "product_quantity"
            case comparedToCategory = "compared_to_category"
            case ingredientsHierarchy = "ingredients_hierarchy"
            case ingredientsTextWithAllergensEn = "ingredients_text_with_allergens_en"
            case ingredientsTextEn = "ingredients_text_en"
            case originsHierarchy = "origins_hierarchy"
            case countriesTags = "countries_tags"
            case genericNameEn = "generic_name_en"
            case imageThumbUrl = "image_thumb_url"
            case packagingTags = "packaging_tags"
            case tracesHierarchy = "traces_hierarchy"
            case creator
            case brandOwnerImported = "brand_owner_imported"
            case productNameEnImported = "product_name_en_imported"
        }

        public let imageNutritionUrl: URL?
        public let labelsTags: [String]?
        public let productQuantity: Int?
        public let comparedToCategory: String?
        public let ingredientsHierarchy: [String]?
        public let ingredientsTextWithAllergensEn: String?
        public let ingredientsTextEn: String?
        public let originsHierarchy: [String]?
        public let countriesTags: [String]?
        public let genericNameEn: String?
        public let imageThumbUrl: URL?
        public let packagingTags: [String]?
        public let tracesHierarchy: [String]?
        public let creator: String?
        public let brandOwnerImported: String?
        public let productNameEnImported: String?
    }
}
