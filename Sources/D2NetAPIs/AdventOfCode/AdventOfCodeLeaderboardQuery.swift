import Foundation
import Logging
import Utils

private let log = Logger(label: "D2NetAPIs.AdventOfCodeLeaderboardQuery")

public struct AdventOfCodeLeaderboardQuery: Sendable{
    @globalActor
    private actor Cache: GlobalActor {
        static let refreshDelay: TimeInterval = 15 * 60
        static let shared = Cache()
        private(set) var timestamp: Date? = nil
        private(set) var board: AdventOfCodeLeaderboard? = nil

        func update(board: AdventOfCodeLeaderboard) {
            self.board = board
            timestamp = Date()
        }
    }

    public let event: String
    public let ownerId: Int

    public init(event: String, ownerId: Int) {
        self.event = event
        self.ownerId = ownerId
    }

    public func perform() async throws -> AdventOfCodeLeaderboard {
        if let ts = await Cache.shared.timestamp, -ts.timeIntervalSinceNow <= Cache.refreshDelay, let board = await Cache.shared.board {
            log.info("Using cached AoC leaderboard")

            return board
        } else {
            log.info("Refreshing AoC leaderboard cache...")

            guard let key = storedNetApiKeys?.adventOfCode?[event] else {
                throw NetApiError.missingApiKey("for Advent of Code \(event)")
            }

            let request = try HTTPRequest(
                host: "adventofcode.com",
                path: "/\(event)/leaderboard/private/view/\(ownerId).json",
                headers: ["Cookie": "session=\(key)"]
            )
            let board = try await request.fetchJSON(as: AdventOfCodeLeaderboard.self)
            await Cache.shared.update(board: board)
            return board
        }
    }
}
