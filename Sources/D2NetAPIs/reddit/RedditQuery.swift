import D2Utils

public struct RedditQuery {
    private let subreddit: String
    private let maxResults: Int
    
    public init(subreddit: String, maxResults: Int = 5) {
        self.subreddit = subreddit
        self.maxResults = maxResults
    }
    
    public func perform(then: @escaping (Result<RedditThing<RedditListing<RedditLink>>, Error>) -> Void) {
        do {
            let request = try HTTPRequest(
                host: "www.reddit.com",
                path: "/r/\(subreddit)/top.json",
                query: ["limit": String(maxResults)],
                headers: ["User-Agent": "swift:d2:v1.0"]
            )
            request.fetchJSONAsync(as: RedditThing<RedditListing<RedditLink>>.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
