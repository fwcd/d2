// Uses MIT-licensed code from https://github.com/fwcd/swift-discord/blob/main/Sources/Discord/User/DiscordPermissions.swift
// Copyright (c) 2016 Erik Little

@preconcurrency import BigInt

/// A user of user permissions.
public struct Permissions: OptionSet, Sendable {
    public var rawValue: BigInt

    /// This user can create invites.
    public static let createInstantInvite = Permissions(rawValue: 1 << 0)
    /// This user can kick members.
    public static let kickMembers = Permissions(rawValue: 1 << 1)
    /// This user can ban members.
    public static let banMembers = Permissions(rawValue: 1 << 2)
    /// This user is an admin.
    public static let administrator = Permissions(rawValue: 1 << 3)
    /// This user can manage channels.
    public static let manageChannels = Permissions(rawValue: 1 << 4)
    /// This user can manage the guild.
    public static let manageGuild = Permissions(rawValue: 1 << 5)
    /// This user can add reactions.
    public static let addReactions = Permissions(rawValue: 1 << 6)
    /// This user can view the audit log.
    public static let viewAuditLog = Permissions(rawValue: 1 << 7)
    /// This user is a priority speaker in a voice channel.
    public static let prioritySpeaker = Permissions(rawValue: 1 << 8)
    /// This user can go live.
    public static let stream = Permissions(rawValue: 1 << 9)
    /// This user can view a channel in a guild, including reading messages.
    public static let viewChannel = Permissions(rawValue: 1 << 10)
    /// This user can send messages.
    public static let sendMessages = Permissions(rawValue: 1 << 11)
    /// This user can send tts messages.
    public static let sendTTSMessages = Permissions(rawValue: 1 << 12)
    /// This user can manage messages.
    public static let manageMessages = Permissions(rawValue: 1 << 13)
    /// This user can embed links.
    public static let embedLinks = Permissions(rawValue: 1 << 14)
    /// This user can attach files.
    public static let attachFiles = Permissions(rawValue: 1 << 15)
    /// This user read the message history.
    public static let readMessageHistory = Permissions(rawValue: 1 << 16)
    /// This user can mention everyone.
    public static let mentionEveryone = Permissions(rawValue: 1 << 17)
    /// This user can can add external emojis.
    public static let useExternalEmojis = Permissions(rawValue: 1 << 18)
    /// This user can view guild insights.
    public static let viewGuildInsights = Permissions(rawValue: 1 << 19)
    /// This user can connect to a voice channel.
    public static let connect = Permissions(rawValue: 1 << 20)
    /// This user can speak on a voice channel.
    public static let speak = Permissions(rawValue: 1 << 21)
    /// This user can mute members.
    public static let muteMembers = Permissions(rawValue: 1 << 22)
    /// This user can deafen members.
    public static let deafenMembers = Permissions(rawValue: 1 << 23)
    /// This user can move members.
    public static let moveMembers = Permissions(rawValue: 1 << 24)
    /// This user can use VAD.
    public static let useVAD = Permissions(rawValue: 1 << 25)
    /// This user can change their nickname.
    public static let changeNickname = Permissions(rawValue: 1 << 26)
    /// This user can manage nicknames.
    public static let manageNicknames = Permissions(rawValue: 1 << 27)
    /// This user can manage roles.
    public static let manageRoles = Permissions(rawValue: 1 << 28)
    /// This user can manage WebHooks
    public static let manageWebhooks = Permissions(rawValue: 1 << 29)
    /// This user can manage emojis and stickers
    public static let manageEmojisAndStickers = Permissions(rawValue: 1 << 30)
    /// This user can use slash commands.
    public static let useSlashCommands = Permissions(rawValue: 1 << 31)
    /// This user can request to speak in stage channels.
    public static let requestToSpeak = Permissions(rawValue: 1 << 32)
    /// This user can delete and archive threads, also view all private threads.
    public static let manageThreads = Permissions(rawValue: 1 << 34)
    /// This user can create and participate in threads.
    public static let usePublicThreads = Permissions(rawValue: 1 << 35)
    /// This user can create and participate in private threads.
    public static let usePrivateThreads = Permissions(rawValue: 1 << 36)
    /// This user can use custom stickers from other servers.
    public static let useExternalStickers = Permissions(rawValue: 1 << 37)

    /// All the channel permissions set to true.
    public static let allChannel = Permissions(rawValue: 0x33F7FC51)

    /// All voice permissions set to true
    public static let voice = Permissions(rawValue: 0x3F00000)

    /// User has all permissions.
    public static let all = Permissions(rawValue: BigInt(UInt64.max))

    public init() {
        rawValue = 0
    }

    public init(rawValue: BigInt) {
        self.rawValue = rawValue
    }

    /// Adds another set of permissions.
    public mutating func formUnion(_ other: Permissions) {
        rawValue |= other.rawValue
    }

    /// Forms the intersection with another set of permissions.
    public mutating func formIntersection(_ other: Permissions) {
        rawValue &= other.rawValue
    }

    /// Forms the symmetric difference between this and another set of permissions.
    public mutating func formSymmetricDifference(_ other: Permissions) {
        rawValue ^= other.rawValue
    }
}
