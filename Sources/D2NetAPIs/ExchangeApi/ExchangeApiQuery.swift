import Utils

public struct ExchangeApiQuery: Sendable {
    public let base: String

    public init(base: String = "EUR") {
        self.base = base
    }

    public func perform() async throws -> ExchangeApiResponse {
        let request = try HTTPRequest(host: "cdn.jsdelivr.net", path: "/npm/@fawazahmed0/currency-api@latest/v1/currencies/\(base.lowercased()).min.json")
        return try await request.fetchJSON(as: ExchangeApiResponse.self)
    }
}
