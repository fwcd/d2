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

    public var year: Int? { Int(event) }
    public var startDate: Date? { challengeReleaseDate(day: 1) }
    public var endDate: Date? { challengeReleaseDate(day: 26) }

    public func challengeReleaseDate(day: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = 12
        components.day = day
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: -5 * 3600)
        return Calendar.current.date(from: components)
    }

    public func timesToCompletion(member: Member, day: Int) -> [TimeInterval] {
        (challengeReleaseDate(day: day).map { [$0] } ?? [])
            .flatMap { release in (member.starCompletions[day] ?? [])
                .compactMap { $0.getStarTs?.date?.timeIntervalSince(release) }
                .filter { $0 >= 0 }
                .scan1 { $1 - $0 } }
    }

    public func timeToCompletion(member: Member, day: Int) -> TimeInterval? {
        timesToCompletion(member: member, day: day).reduce1(+)
    }

    public func lastTimeToCompletion(member: Member) -> TimeInterval? {
        timeToCompletion(member: member, day: member.lastDay)
    }

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

        public var lastDay: Int { starCompletions.keys.max() ?? 1 }
        public var displayName: String { name ?? "<anonymous user \(id ?? "?")>" }
        public var starCompletions: [Int: [StarCompletion]] {
            Dictionary(uniqueKeysWithValues: completionDayLevel?
                .compactMap { (k, v) in Int(k).map { ($0, v.values.sorted()) } }
                ?? [])
        }
        public var starScores: [StarScore] {
            var res = [StarScore]()
            for completion in starCompletions.flatMap(\.value).sorted() {
                if let date = completion.getStarTs?.date ?? res.last?.date {
                    res.append(StarScore(score: (res.last?.score ?? 0) + 1, date: date))
                }
            }
            return res.sorted()
        }

        public struct StarScore: Equatable, Comparable {
            public let score: Int
            public let date: Date

            public init(score: Int, date: Date) {
                self.score = score
                self.date = date
            }

            public func at(date newDate: Date) -> StarScore {
                StarScore(score: score, date: newDate)
            }

            public static func <(lhs: Self, rhs: Self) -> Bool {
                lhs.date < rhs.date
            }
        }

        public struct StarCompletion: Decodable, Equatable, Comparable {
            public enum CodingKeys: String, CodingKey {
                case getStarTs = "get_star_ts"
            }

            public let getStarTs: Timestamp?

            private var date: Date { getStarTs?.date ?? Date.distantFuture }

            public static func <(lhs: Self, rhs: Self) -> Bool {
                lhs.date < rhs.date
            }
        }

        public struct Timestamp: Decodable, Equatable {
            public let date: Date?

            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let raw = try? container.decode(Double.self)
                date = raw.map(Date.init(timeIntervalSince1970:))
            }
        }
    }
}
