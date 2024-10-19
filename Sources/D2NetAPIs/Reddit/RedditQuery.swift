import Utils

public struct RedditQuery: Sendable {
    private let subreddit: String
    private let maxResults: Int

    public init(subreddit: String, maxResults: Int = 5) {
        self.subreddit = subreddit
        self.maxResults = maxResults
    }

    public func perform() async throws -> RedditThing<RedditListing<RedditLink>> {
        try await HTTPRequest(
            host: "www.reddit.com",
            path: "/r/\(subreddit)/top.json",
            query: ["limit": String(maxResults)],
            headers: ["User-Agent": "swift:d2:v1.0"]
        ).fetchJSON(as: RedditThing<RedditListing<RedditLink>>.self)
    }
}
