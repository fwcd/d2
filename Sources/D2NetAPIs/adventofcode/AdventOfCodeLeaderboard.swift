public struct AdventOfCodeLeaderboard: Codable {
    public enum CodingKeys: String, CodingKey {
        case ownerId = "owner_id"
        case event
        case members
    }

    public let ownerId: String
    public let event: String
    public let members: [String: Member]

    public struct Member: Codable {
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
        public let lastStarTs: String?
        public let id: String?
        public let completionDayLevel: [String: [String: StarCompletion]]?
        public let name: String

        public struct StarCompletion: Codable {
            public enum CodingKeys: String, CodingKey {
                case getStarTs = "get_star_ts"
            }

            public let getStarTs: String?
        }
    }
}
