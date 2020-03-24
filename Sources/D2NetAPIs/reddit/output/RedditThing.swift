public struct RedditThing<T>: Codable where T: Codable {
    public let kind: String
    public let data: T
}
