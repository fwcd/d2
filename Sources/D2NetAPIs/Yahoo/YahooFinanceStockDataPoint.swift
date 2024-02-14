public struct YahooFinanceStockDataPoint: Codable {
    public let date: String
    public let `open`: Double
    public let high: Double
    public let low: Double
    public let close: Double
    public let adjClose: Double
    public let volume: Int

    public enum CodingKeys: String, CodingKey {
        case date = "Date"
        case `open` = "Open"
        case high = "High"
        case low = "Low"
        case close = "Close"
        case adjClose = "Adj Close"
        case volume = "Volume"
    }
}
