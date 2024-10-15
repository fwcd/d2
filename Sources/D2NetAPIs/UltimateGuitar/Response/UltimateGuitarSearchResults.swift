public struct UltimateGuitarSearchResults: Sendable, Codable {
    public enum CodingKeys: String, CodingKey {
        case searchQuery = "search_query"
        case searchQueryType = "search_query_type"
        case resultsCount = "results_count"
        case results
    }

    public let searchQuery: String
    public let searchQueryType: String?
    public let resultsCount: Int?
    public let results: [UltimateGuitarTab]
}
