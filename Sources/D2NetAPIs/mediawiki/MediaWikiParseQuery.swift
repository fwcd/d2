import D2Utils

public struct MediaWikiParseQuery {
    private let host: String
    private let path: String
    private let page: String
    private let prop: String
    private let section: String?
    
    public init(host: String, path: String, page: String, prop: String = "wikitext", section: String? = nil) {
        self.host = host
        self.path = path
        self.page = page
        self.prop = prop
        self.section = section
    }
    
    public func perform(then: @escaping (Result<MediaWikiParse, Error>) -> Void) {
        do {
            var query = [
                "action": "parse",
                "page": page,
                "format": "json",
                "prop": prop,
                "formatversion": "2"
            ]

            if let s = section {
                query["section"] = s
            }

            let request = try HTTPRequest(host: host, path: path, query: query)
            request.fetchJSONAsync(as: MediaWikiParse.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
