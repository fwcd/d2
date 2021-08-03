import Foundation
import Utils

// TODO: Make this a protocol and add roles/members properties
public struct Guild {
    public let id: GuildID
    public let ownerId: UserID?
    public let region: String?
    public let large: Bool
    public let name: String
    public let joinedAt: Date?
    public let splash: String
    public let unavailable: Bool
    public let description: String
    public let mfaLevel: Int?
    public let verificationLevel: Int?
    public let widgetEnabled: Bool
    public let widgetChannelId: ChannelID?
    public let icon: String?
    public let members: [UserID: Member]
    public let roles: [RoleID: Role]
    public let presences: [UserID: Presence]
    public let voiceStates: [UserID: VoiceState]
    public let emojis: [EmojiID: Emoji]
    public let channels: [ChannelID: Channel]

    /// Fetches the guild's channels as a tree.
    public var channelTree: [ChannelTreeNode] {
        let treeNodes = channels.mapValues { ChannelTreeNode(channel: $0) }

        for treeNode in treeNodes.values {
            if let parentId = treeNode.channel.parentId, let parent = treeNodes[parentId] {
                parent.childs.append(treeNode)
            }
        }

        for treeNode in treeNodes.values {
            treeNode.childs.sort(by: ascendingComparator(comparing: \.channel.position))
        }

        return treeNodes.values
            .sorted(by: ascendingComparator(comparing: \.channel.position))
            .filter { $0.channel.parentId == nil }
    }

    /// Fetches the channels, correctly ordered. Since this requires
    /// building a channel tree, it is generally considered an expensive
    /// property to compute.
    public var channelsInOrder: [Channel] { channelTree.flatMap(\.traversed) }

    public init(
        id: GuildID = GuildID(""),
        ownerId: UserID? = nil,
        region: String? = nil,
        large: Bool = false,
        name: String = "",
        joinedAt: Date? = nil,
        splash: String = "",
        unavailable: Bool = false,
        description: String = "",
        mfaLevel: Int? = nil,
        verificationLevel: Int? = nil,
        widgetEnabled: Bool = false,
        widgetChannelId: ChannelID? = nil,
        icon: String? = nil,
        members: [UserID: Member] = [:],
        roles: [RoleID: Role] = [:],
        presences: [UserID: Presence] = [:],
        voiceStates: [UserID: VoiceState] = [:],
        emojis: [EmojiID: Emoji] = [:],
        channels: [ChannelID: Channel] = [:]
    ) {
        self.id = id
        self.ownerId = ownerId
        self.region = region
        self.large = large
        self.name = name
        self.joinedAt = joinedAt
        self.splash = splash
        self.unavailable = unavailable
        self.description = description
        self.mfaLevel = mfaLevel
        self.verificationLevel = verificationLevel
        self.widgetEnabled = widgetEnabled
        self.widgetChannelId = widgetChannelId
        self.icon = icon
        self.members = members
        self.roles = roles
        self.presences = presences
        self.voiceStates = voiceStates
        self.emojis = emojis
        self.channels = channels
    }

    public func roles(for member: Member) -> [Role] {
        return member.roleIds.compactMap { roles[$0] }
    }

    public struct Channel: CustomStringConvertible {
        public let id: ChannelID
        public let guildId: GuildID?
        public let name: String
        public let topic: String?
        public let parentId: ChannelID?
        public let position: Int
        public let type: ChannelType
        public let permissionOverwrites: [OverwriteID: PermissionOverwrite]

        public var isVoiceChannel: Bool { type == .voice }
        public var description: String {
            switch type {
                case .text: return "<#\(id)>"
                case .voice: return ":speaker: \(name)"
                case .category: return ":paperclip: \(name)"
                default: return name
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
            permissionOverwrites: [OverwriteID: PermissionOverwrite] = [:]
        ) {
            self.id = id
            self.guildId = guildId
            self.name = name
            self.topic = topic
            self.parentId = parentId
            self.position = position
            self.type = type
            self.permissionOverwrites = permissionOverwrites
        }

        public struct ChannelType: RawRepresentable, Hashable, Codable {
            public var rawValue: Int

            public static let text = ChannelType(rawValue: 0)
            public static let voice = ChannelType(rawValue: 2)
            public static let category = ChannelType(rawValue: 4)

            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
        }

        public struct PermissionOverwrite {
            public let id: OverwriteID
            public let type: PermissionOverwriteType

            public init(id: OverwriteID, type: PermissionOverwriteType) {
                self.id = id
                self.type = type
            }

            public struct PermissionOverwriteType: RawRepresentable, Hashable, Codable {
                public var rawValue: Int

                public static let role = PermissionOverwriteType(rawValue: 0)
                public static let member = PermissionOverwriteType(rawValue: 1)

                public init(rawValue: Int) {
                    self.rawValue = rawValue
                }
            }
        }
    }

    public class ChannelTreeNode {
        public let channel: Channel
        public fileprivate(set) var childs: [ChannelTreeNode] = []

        public var traversed: [Channel] { [channel] + childs.flatMap(\.traversed) }

        fileprivate init(channel: Channel) {
            self.channel = channel
        }
    }

    public struct Member {
        public let guildId: GuildID
        public let joinedAt: Date
        public let user: User
        public let deaf: Bool
        public let mute: Bool
        public let nick: String?
        public let roleIds: [RoleID]

        public init(
            guildId: GuildID,
            joinedAt: Date = Date(),
            user: User,
            deaf: Bool = false,
            mute: Bool = false,
            nick: String? = nil,
            roleIds: [RoleID] = []
        ) {
            self.guildId = guildId
            self.joinedAt = joinedAt
            self.user = user
            self.deaf = deaf
            self.mute = mute
            self.nick = nick
            self.roleIds = roleIds
        }
    }
}
