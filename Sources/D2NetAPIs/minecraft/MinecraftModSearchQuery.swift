import D2Utils

public struct MinecraftModSearchQuery {
    private let params: [String: String]

    public init(
        term: String,
        gameVersion: String = "1.12.2",
        maxResults: Int = 3
    ) {
        params = [
            "categoryId": "0",
            "gameId": "432",
            "gameVersion": gameVersion,
            "index": "0",
            "pageSize": String(maxResults),
            "searchFilter": term,
            "sort": "0"
        ]
    }
    
    public func perform(then: @escaping (Result<[MinecraftModSearchResult], Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "addons-ecs.forgesvc.net", path: "/api/v2/addon/search", query: params)
            request.fetchJSONAsync(as: [MinecraftModSearchResult].self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
