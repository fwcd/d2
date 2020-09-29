import Utils

struct GitLabConfiguration: Codable, DefaultInitializable {
    var serverHost: String? = nil
    var projectId: Int? = nil
}
