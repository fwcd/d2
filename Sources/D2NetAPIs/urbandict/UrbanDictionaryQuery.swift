import D2Utils

public struct UrbanDictionaryQuery {
    private let term: String

    public init(term: String) {
        self.term = term
    }

    public func perform() -> Promise<UrbanDictionarySearchResults, Error> {
        Promise.catching { try HTTPRequest(host: "api.urbandictionary.com", path: "/v0/define", query: ["term": term]) }
            .then { $0.fetchJSONAsync(as: UrbanDictionarySearchResults.self) }
    }
}
