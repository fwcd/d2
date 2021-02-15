import Utils

public struct GiphyTrendingQuery {
    private let limit: Int

    public init(limit: Int = 5) {
        self.limit = limit
    }

    public func perform() -> Promise<GiphyResults, Error> {
        Promise.catching { () -> HTTPRequest in
            guard let key = storedNetApiKeys?.giphy else { throw NetApiError.missingApiKey("No giphy key provided") }
            return try HTTPRequest(host: "api.giphy.com", path: "/v1/gifs/trending", query: [
                "api_key": key,
                "limit": String(limit)
            ])
        }.then { $0.fetchJSONAsync(as: GiphyResults.self) }
    }
}
