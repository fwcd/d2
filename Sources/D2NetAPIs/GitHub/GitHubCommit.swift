public struct GitHubCommit: Sendable, Codable {
    public enum CodingKeys: String, CodingKey {
        case sha
        case nodeId = "node_id"
        case commit
        case url
        case htmlUrl = "html_url"
        case parents
    }

    public let sha: String
    public let url: String
    public let htmlUrl: String

    public let nodeId: String?
    public let commit: Commit?
    public let parents: [GitHubCommit]?

    public struct Commit: Sendable, Codable {
        public let author: Author
        public let committer: Author
        public let message: String
        public let url: String

        public struct Author: Sendable, Codable {
            public let name: String
            public let email: String
            public let date: String
        }
    }
}
