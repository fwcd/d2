import D2Utils

public struct MinecraftWikiParseQuery {
    private let page: String
    
    public init(page: String) {
        self.page = page
    }
    
    public func perform(then: @escaping (Result<MinecraftWikiParse, Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "minecraft.gamepedia.com", path: "/api.php", query: [
                "action": "parse",
                "page": page,
                "format": "json",
                "prop": "wikitext",
                "formatversion": "2"
            ])
            request.fetchJSONAsync(as: MinecraftWikiParse.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
