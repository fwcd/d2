import D2Utils

public struct GitHubCommitsQuery {
    private let user: String
    private let repo: String

    public init(user: String, repo: String) {
        self.user = user
        self.repo = repo
    }

    public func perform() -> Promise<[GitHubCommit], Error> {
        Promise.catching { try HTTPRequest(host: "api.github.com", path: "/repos/\(user)/\(repo)/commits") }
            .then { $0.fetchJSONAsync(as: [GitHubCommit].self) }
    }
}
