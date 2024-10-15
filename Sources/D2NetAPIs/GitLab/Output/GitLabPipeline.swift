public struct GitLabPipeline: Sendable, Codable {
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

    // Detail info

    public let beforeSha: String?
    public let tag: Bool?
    public let user: GitLabUser?
}
