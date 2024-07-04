import Utils

public struct TaylorRestQuery {
    public init() {}

    public func perform() async throws -> TaylorQuote {
        let request = try HTTPRequest(host: "api.taylor.rest", path: "/")
        return try await request.fetchJSON(as: TaylorQuote.self)
    }
}
