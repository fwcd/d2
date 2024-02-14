public struct DiscordStatus: Codable {
    public let page: Page?
    public let components: [Component]?
    public let incidents: [Incident]?
    public let status: Status?

    public struct Page: Codable {
        public enum CodingKeys: String, CodingKey {
            case id
            case name
            case url
            case timeZone = "time_zone"
            case updatedAt = "updated_at"
        }

        public let id: String
        public let name: String
        public let url: String?
        public let timeZone: String?
        public let updatedAt: String?
    }

    public struct Component: Codable {
        public enum CodingKeys: String, CodingKey {
            case id
            case name
            case status
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case position
            case description
            case showcase
            case groupId = "group_id"
            case pageId = "page_id"
            case group
            case onlyShowIfDegraded = "only_show_if_degraded"
        }

        public let id: String
        public let name: String
        public let status: String
        public let createdAt: String?
        public let updatedAt: String?
        public let position: Int?
        public let description: String?
        public let showcase: Bool?
        public let groupId: String?
        public let pageId: String?
        public let group: Bool?
        public let onlyShowIfDegraded: Bool?
    }

    public struct Incident: Codable {
        public let id: String
        public let name: String
    }

    public struct Status: Codable {
        public let indicator: String
        public let description: String
    }
}
