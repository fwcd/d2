import Utils

public struct OpenThesaurusQuery: Sendable {
    private let term: String

    public init(term: String) {
        self.term = term
    }

    public func perform() async throws -> OpenThesaurusResults {
        let request = try HTTPRequest(
            host: "www.openthesaurus.de",
            path: "/synonyme/search",
            query: ["q": term, "format": "application/json"]
        )
        return try await request.fetchJSON(as: OpenThesaurusResults.self)
    }
}
