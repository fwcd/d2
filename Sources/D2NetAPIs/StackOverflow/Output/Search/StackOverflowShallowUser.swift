public struct StackOverflowShallowUser: Sendable, Codable {
    public var reputation: Int?
    public var userId: Int?
    public var userType: String?
    public var acceptRate: Int?
    public var profileImage: String?
    public var displayName: String?
    public var link: String?

    public enum CodingKeys: String, CodingKey {
        case reputation = "reputation"
        case userId = "user_id"
        case userType = "user_type"
        case acceptRate = "accept_rate"
        case profileImage = "profile_image"
        case displayName = "display_name"
        case link = "link"
    }
}
