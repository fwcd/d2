import Utils

public struct ExchangeRatesQuery {
    public let base: String?

    public init(base: String? = nil) {
        self.base = base
    }

    public func perform() async throws -> ExchangeRates {
        let request = try HTTPRequest(host: "api.exchangeratesapi.io", path: "/latest")
        return try await request.fetchJSON(as: ExchangeRates.self)
    }
}
