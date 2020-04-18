public struct AdviceSlip: Codable {
    public enum CodingKeys: String, CodingKey {
        case slipId = "slip_id"
        case advice
    }

    public let slipId: String
    public let advice: String
}
