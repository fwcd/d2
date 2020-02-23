public struct RedditOutput<T>: Codable where T: Codable {
    public let kind: String
    public let data: T
}
