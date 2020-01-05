public struct GitLabPipeline: Codable {
    // Source: https://docs.gitlab.com/ee/api/pipelines.html#get-a-single-pipeline

    public enum CodingKeys: String, CodingKey {
        case id
        case scope
        case status
        case ref
        case sha
        case yamlErrors = "yaml_errors"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case orderBy = "order_by"
        case sort
        case webUrl = "web_url"
        case beforeSha = "before_sha"
        case tag
        case user
    }

    public let id: Int?
    public let scope: String?
    public let status: String?
    public let ref: String?
    public let sha: String?
    public let yamlErrors: Bool?
    public let createdAt: String?
    public let updatedAt: String?
    public let orderBy: String?
    public let sort: String?
    public let webUrl: String?
    
    public var statusEmoji: String {
        switch status {
            case "success"?: return ":white_check_mark:"
            case "failed"?: return ":x:"
            case "running"?: return ":man_running:"
            case "pending"?: return ":hourglass:"
            case "cancelled"?: return ":no_entry_sign:"
            default: return ":question:"
        }
    }
    
    // Detail info
    
    public let beforeSha: String?
    public let tag: Bool?
    public let user: User?
    
    public struct User: Codable {
        public enum CodingKeys: String, CodingKey {
            case name
            case username
            case id
            case state
            case avatarUrl = "avatar_url"
            case webUrl = "web_url"
        }

        public let name: String?
        public let username: String?
        public let id: Int?
        public let state: String?
        public let avatarUrl: String?
        public let webUrl: String?
    }
}
