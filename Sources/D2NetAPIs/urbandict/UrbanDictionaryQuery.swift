import D2Utils

public struct UrbanDictionaryQuery {
    private let term: String
    
    public init(term: String) {
        self.term = term
    }
    
    public func perform(then: @escaping (Result<UrbanDictionarySearchResults, Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "api.urbandictionary.com", path: "/v0/define", query: ["term": term])
            request.fetchJSONAsync(as: UrbanDictionarySearchResults.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
