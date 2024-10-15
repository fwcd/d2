public struct GitLabCommit: Sendable, Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case shortId = "short_id"
        case createdAt = "created_at"
        case parentIds = "parent_ids"
        case title
        case message
        case authorName = "author_name"
        case authorEmail = "author_email"
        case authoredDate = "authored_date"
        case committerName = "committer_name"
        case committerEmail = "committer_email"
        case committedDate = "committed_date"
    }

    public let id: String?
    public let shortId: String?
    public let createdAt: String?
    public let parentIds: [String]?
    public let title: String?
    public let message: String?
    public let authorName: String?
    public let authorEmail: String?
    public let authoredDate: String?
    public let committerName: String?
    public let committerEmail: String?
    public let committedDate: String?
}
