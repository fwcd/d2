import Foundation
import Utils

public struct Message: ExpressibleByStringLiteral {
    public var content: String
    public var embeds: [Embed]
    public var files: [FileUpload]
    public var tts: Bool
    public var components: [Component]

    public var attachments: [Attachment]
    public var activity: Activity?
    public var application: MessageApplication?
    public var author: User?
    public var dm: Bool
    public var channelId: ChannelID?
    public var editedTimestamp: Date?
    public var id: MessageID?
    public var nonce: ID?
    public var pinned: Bool
    public var reactions: [Reaction]
    public var timestamp: Date?
    public var type: MessageType?
    public var guild: Guild?
    public var guildMember: Guild.Member?

    public var mentionEveryone: Bool
    public var mentionRoles: [RoleID]
    public var mentions: [User]

    public var embed: Embed? { embeds.first }

    /// Pure-string initializer without argument label for convenience.
    public init(_ content: String = "") {
        self.init(content: content)
    }

    /// Initializer intended for messages that are to be sent.
    public init(
        content: String = "",
        embed: Embed? = nil,
        files: [FileUpload] = [],
        tts: Bool = false,
        components: [Component] = []
    ) {
        self.init(
            content: content,
            embeds: embed.map { [$0] } ?? [],
            files: files,
            tts: tts,
            components: components
        )
    }

    /// Initializer intended for received/arbitrary messages.
    public init(
        content: String,
        embeds: [Embed] = [],
        files: [FileUpload] = [],
        tts: Bool = false,
        components: [Component] = [],
        attachments: [Attachment] = [],
        activity: Activity? = nil,
        application: MessageApplication? = nil,
        author: User? = nil,
        channelId: ChannelID? = nil,
        dm: Bool = false,
        editedTimestamp: Date? = nil,
        id: MessageID? = nil,
        mentionEveryone: Bool = false,
        mentionRoles: [RoleID] = [],
        mentions: [User] = [],
        nonce: ID? = nil,
        pinned: Bool = false,
        reactions: [Reaction] = [],
        timestamp: Date? = nil,
        type: MessageType? = nil,
        guild: Guild? = nil,
        guildMember: Guild.Member? = nil
    ) {
        self.content = content
        self.embeds = embeds
        self.files = files
        self.tts = tts
        self.components = components
        self.attachments = attachments
        self.activity = activity
        self.application = application
        self.author = author
        self.dm = dm
        self.channelId = channelId
        self.editedTimestamp = editedTimestamp
        self.id = id
        self.mentionEveryone = mentionEveryone
        self.mentionRoles = mentionRoles
        self.mentions = mentions
        self.nonce = nonce
        self.pinned = pinned
        self.reactions = reactions
        self.timestamp = timestamp
        self.type = type
        self.guild = guild
        self.guildMember = guildMember
    }

    public init(stringLiteral value: String) {
        self.init(content: value)
    }

    public struct Edit {
        public var content: String?
        public var embeds: [Embed]?
        public var components: [Component]?

        public init(
            content: String? = nil,
            embeds: [Embed]? = nil,
            components: [Component]? = nil
        ) {
            self.content = content
            self.embeds = embeds
            self.components = components
        }
    }

    public struct FileUpload {
        public let data: Data
        public let filename: String
        public let mimeType: String

        public init(data: Data, filename: String, mimeType: String) {
            self.data = data
            self.filename = filename
            self.mimeType = mimeType
        }
    }

    public struct Attachment {
        public let id: AttachmentID
        public let filename: String
        public let size: Int
        public let url: URL?
        public let width: Int?
        public let height: Int?

        public init(id: AttachmentID, filename: String, size: Int = 0, url: URL? = nil, width: Int? = nil, height: Int? = nil) {
            self.id = id
            self.filename = filename
            self.size = size
            self.url = url
            self.width = width
            self.height = height
        }
    }

    public struct Activity {
        public let type: ActivityType
        public let partyId: String?

        public init(type: ActivityType, partyId: String? = nil) {
            self.type = type
            self.partyId = partyId
        }

        public struct ActivityType: Hashable, Codable, RawRepresentable {
            public var rawValue: Int

            public static let join = ActivityType(rawValue: 1)
            public static let spectate = ActivityType(rawValue: 2)
            public static let listen = ActivityType(rawValue: 3)
            public static let joinRequest = ActivityType(rawValue: 4)

            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
        }
    }

    public enum Component {
        case button(Button)
        case selectMenu(SelectMenu)
        case actionRow(ActionRow)

        public var primitiveChildren: [Component] {
            if case let .actionRow(row) = self {
                return row.components.flatMap(\.primitiveChildren)
            } else {
                return [self]
            }
        }

        public struct Button {
            public var customId: String
            public var style: Style?
            public var label: String?
            public var disabled: Bool?

            // TODO: Emojis & co

            public init(
                customId: String,
                style: Style = .primary,
                label: String? = nil,
                disabled: Bool? = nil
            ) {
                self.customId = customId
                self.style = style
                self.label = label
                self.disabled = disabled
            }

            public enum Style {
                case primary
                case secondary
                case success
                case danger
                case link
            }
        }

        public struct SelectMenu {
            public var customId: String
            public var options: [Option]
            public var placeholder: String?
            public var minValues: Int?
            public var maxValues: Int?
            public var disabled: Bool?

            public init(
                customId: String,
                options: [Option],
                placeholder: String? = nil,
                minValues: Int? = nil,
                maxValues: Int? = nil,
                disabled: Bool? = nil
            ) {
                self.customId = customId
                self.options = options
                self.placeholder = placeholder
                self.minValues = minValues
                self.maxValues = maxValues
                self.disabled = disabled
            }

            public struct Option {
                public var label: String
                public var value: String
                public var description: String?
                public var emoji: Emoji?
                public var `default`: Bool?

                public init(
                    label: String,
                    value: String,
                    description: String? = nil,
                    emoji: Emoji? = nil,
                    default: Bool? = nil
                ) {
                    self.label = label
                    self.value = value
                    self.description = description
                    self.emoji = emoji
                    self.default = `default`
                }
            }
        }

        public struct ActionRow {
            public let components: [Component]

            public init(components: [Component]) {
                self.components = components
            }
        }
    }

    public struct MessageApplication {
        public var id: ID
        public var coverImage: String?
        public var description: String?
        public var icon: String?
        public var name: String?

        public init(id: ID, coverImage: String? = nil, description: String? = nil, icon: String? = nil, name: String? = nil) {
            self.id = id
            self.coverImage = coverImage
            self.description = description
            self.icon = icon
            self.name = name
        }
    }

    public struct Reaction {
        public var count: Int
        public var me: Bool
        public var emoji: Emoji

        public var users: [UserID]?

        public init(count: Int, me: Bool, emoji: Emoji, users: [UserID]? = nil) {
            self.count = count
            self.me = me
            self.emoji = emoji
            self.users = users
        }
    }

    public struct MessageType: Hashable, RawRepresentable, Codable {
        public var rawValue: Int

        public static let `default` = MessageType(rawValue: 0)
        public static let recipientAdd = MessageType(rawValue: 1)
        public static let recipientRemove = MessageType(rawValue: 2)
        public static let call = MessageType(rawValue: 3)
        public static let channelNameChange = MessageType(rawValue: 4)
        public static let channelIconChange = MessageType(rawValue: 5)
        public static let channelPinnedMessage = MessageType(rawValue: 6)
        public static let guildMemberJoin = MessageType(rawValue: 7)
        public static let userPremiumGuildSubscription = MessageType(rawValue: 8)
        public static let userPremiumGuildSubscriptionTier1 = MessageType(rawValue: 9)
        public static let userPremiumGuildSubscriptionTier2 = MessageType(rawValue: 10)
        public static let userPremiumGuildSubscriptionTier3 = MessageType(rawValue: 11)
        public static let channelFollowAdd = MessageType(rawValue: 12)
        public static let guildDiscoveryDisqualified = MessageType(rawValue: 13)
        public static let guildDiscoveryRequalified = MessageType(rawValue: 14)
        public static let reply = MessageType(rawValue: 15)

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}
