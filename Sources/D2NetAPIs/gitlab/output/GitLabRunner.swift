public struct GitLabRunner: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case description
        case ipAddress = "ip_address"
        case active
        case isShared = "is_shared"
        case name
        case online
        case status
    }

    public let id: Int?
    public let description: String?
    public let ipAddress: String?
    public let active: Bool?
    public let isShared: Bool?
    public let name: String?
    public let online: Bool?
    public let status: String?
}
