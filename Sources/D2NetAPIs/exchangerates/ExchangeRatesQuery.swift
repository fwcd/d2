import Utils

public struct ExchangeRatesQuery {
    public let base: String?

    public init(base: String? = nil) {
        self.base = base
    }

    public func perform() -> Promise<ExchangeRates, Error> {
        Promise.catching { try HTTPRequest(host: "api.exchangeratesapi.io", path: "/latest") }
            .then { $0.fetchJSONAsync(as: ExchangeRates.self) }
    }
}
