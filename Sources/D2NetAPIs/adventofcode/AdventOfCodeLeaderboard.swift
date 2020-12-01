import Foundation
import Utils

public struct AdventOfCodeLeaderboard: Decodable {
    public enum CodingKeys: String, CodingKey {
        case ownerId = "owner_id"
        case event
        case members
    }

    public let ownerId: String
    public let event: String
    public let members: [String: Member]

    public struct Member: Decodable {
        public enum CodingKeys: String, CodingKey {
            case stars
            case globalScore = "global_score"
            case localScore = "local_score"
            case lastStarTs = "last_star_ts"
            case id
            case completionDayLevel = "completion_day_level"
            case name
        }

        public let stars: Int
        public let globalScore: Int?
        public let localScore: Int?
        public let lastStarTs: Timestamp? // String or Int
        public let id: String?
        public let completionDayLevel: [String: [String: StarCompletion]]?
        public let name: String?

        public var displayName: String { name ?? "<anonymous user \(id ?? "?")>" }
        public var starCompletions: [StarCompletion] {
            completionDayLevel?
                .values
                .flatMap(\.values)
                .sorted(by: ascendingComparator { $0.getStarTs?.date ?? Date.distantFuture })
                ?? []
        }
        public var starScores: [StarScore] {
            var res = [StarScore]()
            for completion in starCompletions {
                if let date = completion.getStarTs?.date ?? res.last?.date {
                    res.append(StarScore(score: (res.last?.score ?? 0) + 1, date: date))
                }
            }
            return res
        }

        public struct StarScore {
            public let score: Int
            public let date: Date
        }

        public struct StarCompletion: Decodable {
            public enum CodingKeys: String, CodingKey {
                case getStarTs = "get_star_ts"
            }

            public let getStarTs: Timestamp?
        }

        public struct Timestamp: Decodable {
            public let date: Date?

            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let raw = try? container.decode(String.self)
                date = raw.flatMap(Double.init).map(Date.init(timeIntervalSince1970:))
            }
        }
    }
}
