import Utils

public struct GiphySearchQuery: Sendable {
    private let term: String
    private let limit: Int

    public init(term: String, limit: Int = 5) {
        self.term = term
        self.limit = limit
    }

    public func perform() async throws -> GiphyResults {
        guard let key = storedNetApiKeys?.giphy else { throw NetApiError.missingApiKey("No giphy key provided") }
        let request = try HTTPRequest(host: "api.giphy.com", path: "/v1/gifs/search", query: [
            "api_key": key,
            "q": term,
            "limit": String(limit)
        ])
        return try await request.fetchJSON(as: GiphyResults.self)
    }
}
