import Utils

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

    public func perform() -> Promise<MediaWikiParse, Error> {
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

        return Promise.catching { try HTTPRequest(host: host, path: path, query: query) }
            .then { $0.fetchJSONAsync(as: MediaWikiParse.self) }
    }
}
