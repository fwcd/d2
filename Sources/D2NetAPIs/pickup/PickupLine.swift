public struct PickupLine: Codable {
    public let username: String?
    public let tweet: String

    public init(username: String? = nil, tweet: String) {
        self.username = username
        self.tweet = tweet
    }
}
