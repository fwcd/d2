import Foundation

public struct Channel: CustomStringConvertible {
    public let id: ChannelID
    public let guildId: GuildID?
    public let name: String
    public let topic: String?
    public let parentId: ChannelID?
    public let position: Int
    public let type: ChannelType
    public let threadMetadata: ThreadMetadata?
    public let permissionOverwrites: [OverwriteID: PermissionOverwrite]

    public var isVoice: Bool { type.isVoice }
    public var isThread: Bool { type.isThread }

    public var description: String {
        switch type {
            case .voice: ":speaker: \(name)"
            case .category: ":paperclip: \(name)"
            default: "<#\(id)>"
        }
    }

    public init(
        id: ChannelID = ChannelID(""),
        guildId: GuildID? = nil,
        name: String = "",
        topic: String? = nil,
        parentId: ChannelID? = nil,
        position: Int = 0,
        type: ChannelType = .text,
        threadMetadata: ThreadMetadata? = nil,
        permissionOverwrites: [OverwriteID: PermissionOverwrite] = [:]
    ) {
        self.id = id
        self.guildId = guildId
        self.name = name
        self.topic = topic
        self.parentId = parentId
        self.position = position
        self.type = type
        self.threadMetadata = threadMetadata
        self.permissionOverwrites = permissionOverwrites
    }

    public struct ChannelType: RawRepresentable, Sendable, Hashable, Codable, Comparable {
        public var rawValue: Int

        public var isVoice: Bool { [.voice, .stageVoice].contains(self) }
        public var isThread: Bool { [.publicThread, .privateThread, .newsThread].contains(self) }

        public static let unknown = ChannelType(rawValue: -1)
        public static let text = ChannelType(rawValue: 0)
        public static let dm = ChannelType(rawValue: 1)
        public static let voice = ChannelType(rawValue: 2)
        public static let groupDM = ChannelType(rawValue: 3)
        public static let category = ChannelType(rawValue: 4)
        public static let news = ChannelType(rawValue: 5)
        public static let store = ChannelType(rawValue: 6)
        public static let newsThread = ChannelType(rawValue: 7)
        public static let publicThread = ChannelType(rawValue: 8)
        public static let privateThread = ChannelType(rawValue: 9)
        public static let stageVoice = ChannelType(rawValue: 10)

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static func <(lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    public struct PermissionOverwrite {
        public let id: OverwriteID
        public let type: PermissionOverwriteType

        public init(id: OverwriteID, type: PermissionOverwriteType) {
            self.id = id
            self.type = type
        }

        public struct PermissionOverwriteType: RawRepresentable, Sendable, Hashable, Codable {
            public var rawValue: Int

            public static let role = PermissionOverwriteType(rawValue: 0)
            public static let member = PermissionOverwriteType(rawValue: 1)

            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
        }
    }

    public struct ThreadMetadata {
        public let archived: Bool
        public let autoArchiveDuration: Int?
        public let archiveTimestamp: Date?
        public let locked: Bool?

        public init(
            archived: Bool = false,
            autoArchiveDuration: Int? = nil,
            archiveTimestamp: Date? = nil,
            locked: Bool? = nil
        ) {
            self.archived = archived
            self.autoArchiveDuration = autoArchiveDuration
            self.archiveTimestamp = archiveTimestamp
            self.locked = locked
        }
    }
}
