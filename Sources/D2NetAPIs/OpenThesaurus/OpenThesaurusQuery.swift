import Utils

public struct OpenThesaurusQuery {
    private let term: String

    public init(term: String) {
        self.term = term
    }

    public func perform() -> Promise<OpenThesaurusResults, any Error> {
        Promise.catching { try HTTPRequest(host: "www.openthesaurus.de", path: "/synonyme/search", query: ["q": term, "format": "application/json"]) }
            .then { $0.fetchJSONAsync(as: OpenThesaurusResults.self) }
    }
}
