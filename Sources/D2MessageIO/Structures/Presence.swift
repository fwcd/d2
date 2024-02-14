import Foundation

public struct Presence {
    public let guildId: GuildID?
    public let user: User
    public let activities: [Activity]
    public let nick: String?
    public let roles: [String]
    public let status: Status?

    public init(guildId: GuildID? = nil, user: User, activities: [Activity] = [], nick: String? = nil, roles: [String] = [], status: Presence.Status? = nil) {
        self.guildId = guildId
        self.user = user
        self.activities = activities
        self.nick = nick
        self.roles = roles
        self.status = status
    }

    public struct Activity: Codable {
        public let name: String
        public let assets: Assets?
        public let details: String?
        public let party: Party?
        public let state: String?
        public let timestamps: Timestamps?
        public let type: ActivityType
        public let url: String?

        public init(name: String, assets: Assets? = nil, details: String? = nil, party: Party? = nil, state: String? = nil, timestamps: Timestamps? = nil, type: ActivityType, url: String? = nil) {
            self.name = name
            self.assets = assets
            self.details = details
            self.party = party
            self.state = state
            self.timestamps = timestamps
            self.type = type
            self.url = url
        }

        public struct Assets: Codable {
            public let largeImage: String?
            public let largeText: String?
            public let smallImage: String?
            public let smallText: String?

            public init(largeImage: String? = nil, largeText: String? = nil, smallImage: String? = nil, smallText: String? = nil) {
                self.largeImage = largeImage
                self.largeText = largeText
                self.smallImage = smallImage
                self.smallText = smallText
            }
        }

        public struct Party: Codable {
            public let id: String?
            public let sizes: [Int]?

            public init(id: String? = nil, sizes: [Int]? = nil) {
                self.id = id
                self.sizes = sizes
            }
        }

        public struct Timestamps: Codable {
            public let start: Date?
            public let end: Date?

            public var interval: TimeInterval? { start.map { (end ?? Date()).timeIntervalSince($0) } }

            public init(start: Date? = nil, end: Date? = nil) {
                self.start = start
                self.end = end
            }
        }

        public struct ActivityType: RawRepresentable, Hashable, Codable {
            public var rawValue: Int

            public static let game = ActivityType(rawValue: 0)
            public static let stream = ActivityType(rawValue: 1)
            public static let listening = ActivityType(rawValue: 2)
            public static let watching = ActivityType(rawValue: 3)
            public static let custom = ActivityType(rawValue: 4)
            public static let competing = ActivityType(rawValue: 5)

            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
        }
    }

    public struct Status: RawRepresentable, Hashable, Codable {
        public var rawValue: String

        public static let idle = Status(rawValue: "idle")
        public static let offline = Status(rawValue: "offline")
        public static let online = Status(rawValue: "online")
        public static let doNotDisturb = Status(rawValue: "doNotDisturb")

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

public struct PresenceUpdate: Codable {
    public let activities: [Presence.Activity]
    public let status: Presence.Status
    public let afkSince: Date?

    public init(activities: [Presence.Activity] = [], status: Presence.Status = .online, afkSince: Date? = nil) {
        self.activities = activities
        self.status = status
        self.afkSince = afkSince
    }
}
