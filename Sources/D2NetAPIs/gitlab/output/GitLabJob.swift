public struct GitLabJob: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case status
        case stage
        case name
        case ref
        case tag
        case allowFailure = "allow_failure"
        case createdAt = "created_at"
        case startedAt = "started_at"
        case finishedAt = "finished_at"
        case duration
        case user
        case commit
        case pipeline
        case webUrl = "web_url"
        case artifacts
        case runner
        case artifactsExpireAt = "artifactsExpireAt"
    }

    public let id: Int?
    public let status: String?
    public let stage: String?
    public let name: String?
    public let ref: String?
    public let tag: Bool?
    public let allowFailure: Bool?
    public let createdAt: String?
    public let startedAt: String?
    public let finishedAt: String?
    public let duration: Double?
    public let user: GitLabUser?
    public let commit: GitLabCommit?
    public let pipeline: GitLabPipeline?
    public let webUrl: String?
    public let artifacts: [GitLabArtifact]?
    public let runner: GitLabRunner?
    public let artifactsExpireAt: String?
}
