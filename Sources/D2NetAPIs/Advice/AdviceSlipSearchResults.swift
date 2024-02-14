public struct AdviceSlipSearchResults: Codable {
    public enum CodingKeys: String, CodingKey {
        case totalResults = "total_results"
        case query
        case slips
    }
    public let totalResults: Int
    public let query: String
    public let slips: [AdviceSlip]
}
