import D2Utils

public struct WikipediaPageQuery {
    private let page: String
    
    public init(pageName: String) {
        page = pageName
            .withFirstUppercased
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: " ", with: "_")
    }
    
    public func perform(then: @escaping (Result<WikipediaPage, Error>) -> Void) {
        do {
            try HTTPRequest(
                host: "en.wikipedia.org",
                path: "/api/rest_v1/page/summary/\(page)"
            ).fetchJSONAsync(as: WikipediaPage.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
