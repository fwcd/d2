public struct ExchangeRatesIoResponse: Sendable, Codable {
    public let rates: [String: Double]
    public let base: String
}
