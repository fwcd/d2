public struct RedditListing: Codable {
    public let modhash: String?
    public let dist: Int?
    public let children: [RedditOutput<RedditPost>]?
}
