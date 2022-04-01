import Utils

public struct EpicFreeGamesQuery {
    public init() {}

    public func perform() -> Promise<EpicFreeGames, any Error> {
        Promise.catching {
            try HTTPRequest(
                host: "store-site-backend-static.ak.epicgames.com",
                path: "/freeGamesPromotions",
                query: ["locale": "en-US"]
            )
        }.then { $0.fetchJSONAsync(as: EpicFreeGames.self) }
    }
}
