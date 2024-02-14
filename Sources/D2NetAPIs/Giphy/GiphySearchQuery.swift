import Utils

public struct GiphySearchQuery {
    private let term: String
    private let limit: Int

    public init(term: String, limit: Int = 5) {
        self.term = term
        self.limit = limit
    }

    public func perform() -> Promise<GiphyResults, any Error> {
        Promise.catching { () -> HTTPRequest in
            guard let key = storedNetApiKeys?.giphy else { throw NetApiError.missingApiKey("No giphy key provided") }
            return try HTTPRequest(host: "api.giphy.com", path: "/v1/gifs/search", query: [
                "api_key": key,
                "q": term,
                "limit": String(limit)
            ])
        }.then { $0.fetchJSONAsync(as: GiphyResults.self) }
    }
}
