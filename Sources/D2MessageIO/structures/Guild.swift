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
    public let threads: [ChannelID: Channel]

    /// Fetches the guild's channels and threads as a tree.
    public var channelTree: [ChannelTreeNode] {
        let treeNodes = channels
            .merging(threads, uniquingKeysWith: { k, _ in k })
            .mapValues { ChannelTreeNode(channel: $0) }

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
        channels: [ChannelID: Channel] = [:],
        threads: [ChannelID: Channel] = [:]
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
        self.threads = threads
    }

    public func roles(for member: Member) -> [Role] {
        member.roleIds.compactMap { roles[$0] }
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
