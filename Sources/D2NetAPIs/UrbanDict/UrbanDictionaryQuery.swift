import Utils

public struct UrbanDictionaryQuery: Sendable {
    private let term: String

    public init(term: String) {
        self.term = term
    }

    public func perform() async throws -> UrbanDictionarySearchResults {
        let request = try HTTPRequest(host: "api.urbandictionary.com", path: "/v0/define", query: ["term": term])
        return try await request.fetchJSON(as: UrbanDictionarySearchResults.self)
    }
}
