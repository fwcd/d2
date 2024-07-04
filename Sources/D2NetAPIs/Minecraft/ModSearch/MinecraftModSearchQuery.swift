import Utils

public struct MinecraftModSearchQuery {
    private let params: [String: String]

    public init(
        term: String,
        maxResults: Int = 3
    ) {
        params = [
            "categoryId": "0",
            "gameId": "432",
            "index": "0",
            "pageSize": String(maxResults),
            "searchFilter": term,
            "sort": "0"
        ]
    }

    public func perform() async throws -> [MinecraftModSearchResult] {
        let request = try HTTPRequest(host: "addons-ecs.forgesvc.net", path: "/api/v2/addon/search", query: params)
        return try await request.fetchJSON(as: [MinecraftModSearchResult].self)
    }
}
