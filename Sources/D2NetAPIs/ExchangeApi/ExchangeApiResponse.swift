import Utils

public struct ExchangeApiResponse: Decodable {
    public let date: String
    public let rates: [String: Double]

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        date = try container.decode(String.self, forKey: "date")
        let baseKeys = container.allKeys.filter { $0 != "date" }
        guard baseKeys.count == 1, let baseKey = baseKeys.first else {
            throw ExchangeApiError.ambiguousBaseCurrency(baseKeys.map(\.stringValue))
        }
        rates = try container.decode([String: Double].self, forKey: baseKey)
    }
}
