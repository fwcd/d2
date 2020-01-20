import D2Utils

public struct WikipediaPageQuery {
    private let pageName: String
    
    public init(pageName: String) {
        self.pageName = pageName
    }
    
    public func perform(then: @escaping (Result<WikipediaPage, Error>) -> Void) {
        do {
            try HTTPRequest(
                host: "en.wikipedia.org",
                path: "/api/rest_v1/page/summary/\(pageName.replacingOccurrences(of: "/", with: ""))"
            ).fetchJSONAsync(as: WikipediaPage.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
