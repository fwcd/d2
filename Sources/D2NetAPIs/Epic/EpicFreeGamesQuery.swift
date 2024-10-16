import Utils

public struct EpicFreeGamesQuery: Sendable {
    public init() {}

    public func perform() async throws -> EpicFreeGames {
        let request = try HTTPRequest(
            host: "store-site-backend-static.ak.epicgames.com",
            path: "/freeGamesPromotions",
            query: ["locale": "en-US"]
        )
        return try await request.fetchJSON(as: EpicFreeGames.self)
    }
}
