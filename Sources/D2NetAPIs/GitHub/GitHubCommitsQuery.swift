import Utils

public struct GitHubCommitsQuery {
    private let user: String
    private let repo: String

    public init(user: String, repo: String) {
        self.user = user
        self.repo = repo
    }

    public func perform() async throws -> [GitHubCommit] {
        let request = try HTTPRequest(host: "api.github.com", path: "/repos/\(user)/\(repo)/commits")
        return try await request.fetchJSON(as: [GitHubCommit].self)
    }
}
