public struct GitLabUser: Sendable, Codable {
    public enum CodingKeys: String, CodingKey {
        case name
        case username
        case id
        case state
        case avatarUrl = "avatar_url"
        case webUrl = "web_url"
        case createdAt = "created_at"
        case bio
        case location
        case publicEmail = "public_email"
        case skype
        case linkedin
        case twitter
        case websiteUrl = "website_url"
        case organization
    }

    public let name: String?
    public let username: String?
    public let id: Int?
    public let state: String?
    public let avatarUrl: String?
    public let webUrl: String?
    public let createdAt: String?
    public let bio: String?
    public let location: String?
    public let publicEmail: String?
    public let skype: String?
    public let linkedin: String?
    public let twitter: String?
    public let websiteUrl: String?
    public let organization: String?
}
