public struct RedditListing<T> {
    public let modhash: String?
    public let dist: Int?
    public let children: [RedditThing<T>]?
    public let before: String?
    public let after: String?
}

extension RedditListing: Sendable where T: Sendable {}
extension RedditListing: Encodable where T: Encodable {}
extension RedditListing: Decodable where T: Decodable {}
