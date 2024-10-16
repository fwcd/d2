import Utils

public struct ExchangeRatesIoQuery: Sendable {
    public let base: String?

    public init(base: String? = nil) {
        self.base = base
    }

    public func perform() async throws -> ExchangeRatesIoResponse {
        let request = try HTTPRequest(host: "api.exchangeratesapi.io", path: "/latest")
        return try await request.fetchJSON(as: ExchangeRatesIoResponse.self)
    }
}
