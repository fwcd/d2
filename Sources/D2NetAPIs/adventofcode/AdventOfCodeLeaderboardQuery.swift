import Foundation
import Logging
import Utils

fileprivate let log = Logger(label: "D2NetAPIs.AdventOfCodeLeaderboardQuery")

public struct AdventOfCodeLeaderboardQuery {
    private static var cachedBoard: AdventOfCodeLeaderboard? = nil
    private static var cachedTimestamp: Date? = nil
    private static let cacheRefreshDelay: TimeInterval = 15 * 60

    public let event: String
    public let ownerId: Int

    public init(event: String, ownerId: Int) {
        self.event = event
        self.ownerId = ownerId
    }

    public func perform() -> Promise<AdventOfCodeLeaderboard, any Error> {
        if let ts = Self.cachedTimestamp, -ts.timeIntervalSinceNow <= Self.cacheRefreshDelay, let board = Self.cachedBoard {
            log.info("Using cached AoC leaderboard")

            return Promise(.success(board))
        } else {
            log.info("Refreshing AoC leaderboard cache...")

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
                .peekListen {
                    if case let .success(board) = $0 {
                        Self.cachedBoard = board
                        Self.cachedTimestamp = Date()
                    }
                }
        }
    }
}
