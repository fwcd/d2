public struct ExchangeRatesIoResponse: Codable {
    public let rates: [String: Double]
    public let base: String
}
