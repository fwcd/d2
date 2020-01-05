import D2Utils

public struct GitLabConfiguration: Codable, DefaultInitializable {
    public var serverHost: String? = nil
    public var projectId: Int? = nil
    
    public init() {}
}
