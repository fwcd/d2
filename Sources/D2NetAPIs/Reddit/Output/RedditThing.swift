public struct RedditThing<T> {
    public let kind: String
    public let data: T
}

extension RedditThing: Sendable where T: Sendable {}
extension RedditThing: Encodable where T: Encodable {}
extension RedditThing: Decodable where T: Decodable {}
