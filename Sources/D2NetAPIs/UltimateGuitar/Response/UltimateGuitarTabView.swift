public struct UltimateGuitarTabView: Sendable, Codable {
    public enum CodingKeys: String, CodingKey {
        case wikiTab = "wiki_tab"
        case contributors
    }

    public let wikiTab: WikiTab?
    public let contributors: [Contributor]?

    public struct WikiTab: Sendable, Codable {
        public enum CodingKeys: String, CodingKey {
            case content
            case revisionId = "revision_id"
            case userId = "user_id"
            case username
            case date
        }

        public let content: String?
        public let revisionId: Int?
        public let userId: Int?
        public let username: String?
        public let date: Int?
    }

    public struct Contributor: Sendable, Codable {
        public enum CodingKeys: String, CodingKey {
            case userId = "userid"
            case username
            case userGroupId = "usergroupid"
            case iq
        }

        public let userId: Int?
        public let username: String?
        public let userGroupId: Int?
        public let iq: Int?
    }
}
