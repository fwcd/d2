public struct GitLabArtifact: Sendable, Codable {
    public enum CodingKeys: String, CodingKey {
        case fileType = "file_type"
        case size
        case filename
    }

    public let fileType: String?
    public let size: Int?
    public let filename: String?
}
