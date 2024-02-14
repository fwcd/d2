public struct RedditListing<T>: Codable where T: Codable {
    public let modhash: String?
    public let dist: Int?
    public let children: [RedditThing<T>]?
    public let before: String?
    public let after: String?
}
