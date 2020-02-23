import D2Utils

public struct RedditQuery {
    private let subreddit: String
    private let maxResults: Int
    
    public init(subreddit: String, maxResults: Int = 5) {
        self.subreddit = subreddit
        self.maxResults = maxResults
    }
    
    public func perform(then: @escaping (Result<RedditOutput<RedditListing>, Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "www.reddit.com", path: "/r/\(subreddit)/top.json", query: ["limit": String(maxResults)])
            request.fetchJSONAsync(as: RedditOutput<RedditListing>.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
