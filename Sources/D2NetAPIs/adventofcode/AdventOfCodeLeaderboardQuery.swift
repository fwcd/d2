import Utils

public struct AdventOfCodeLeaderboardQuery {
    public let event: String
    public let ownerId: Int

    public init(event: String, ownerId: Int) {
        self.event = event
        self.ownerId = ownerId
    }

    public func perform() -> Promise<AdventOfCodeLeaderboard, Error> {
        guard let key = storedNetApiKeys?.adventOfCode?[event] else {
            return Promise(.failure(NetApiError.missingApiKey("for Advent of Code \(event)")))
        }

        return Promise
            .catching { try HTTPRequest(
                host: "adventofcode.com",
                path: "/\(event)/leaderboard/private/view/\(ownerId).json",
                headers: ["Cookie": "session=\(key)"]
            ) }
            .then { $0.fetchJSONAsync(as: AdventOfCodeLeaderboard.self) }
    }
}
