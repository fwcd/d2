import D2Utils

public struct MinecraftWikiParseQuery {
    private let page: String
    private let prop: String
    private let section: String?
    
    public init(page: String, prop: String = "wikitext", section: String? = nil) {
        self.page = page
        self.prop = prop
        self.section = section
    }
    
    public func perform(then: @escaping (Result<MinecraftWikiParse, Error>) -> Void) {
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

            let request = try HTTPRequest(host: "minecraft.gamepedia.com", path: "/api.php", query: query)
            request.fetchJSONAsync(as: MinecraftWikiParse.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
