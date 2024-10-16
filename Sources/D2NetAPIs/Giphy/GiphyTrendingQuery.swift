import Utils

public struct GiphyTrendingQuery: Sendable {
    private let limit: Int

    public init(limit: Int = 5) {
        self.limit = limit
    }

    public func perform() async throws -> GiphyResults {
        guard let key = storedNetApiKeys?.giphy else { throw NetApiError.missingApiKey("No giphy key provided") }
        let request = try HTTPRequest(host: "api.giphy.com", path: "/v1/gifs/trending", query: [
            "api_key": key,
            "limit": String(limit)
        ])
        return try await request.fetchJSON(as: GiphyResults.self)
    }
}
