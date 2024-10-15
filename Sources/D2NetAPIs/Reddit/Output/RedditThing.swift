public struct RedditThing<T>: Codable where T: Sendable, Codable {
    public let kind: String
    public let data: T
}
