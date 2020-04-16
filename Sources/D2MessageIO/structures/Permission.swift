// Uses MIT-licensed code from https://github.com/nuclearace/SwiftDiscord/blob/master/Sources/SwiftDiscord/User/DiscordPermission.swift
// Copyright (c) 2016 Erik Little

public struct Permission: OptionSet {
    public let rawValue: Int

    /// This user can create invites.
    public static let createInstantInvite = Permission(rawValue: 0x00000001)
    /// This user can kick members.
    public static let kickMembers = Permission(rawValue: 0x00000002)
    /// This user can ban members.
    public static let banMembers = Permission(rawValue: 0x00000004)
    /// This user is an admin.
    public static let administrator = Permission(rawValue: 0x00000008)
    /// This user can manage channels.
    public static let manageChannels = Permission(rawValue: 0x00000010)
    /// This user can manage the guild.
    public static let manageGuild = Permission(rawValue: 0x00000020)
    /// This user can add reactions.
    public static let addReactions = Permission(rawValue: 0x00000040)
    /// This user can view the audit log.
    public static let viewAuditLog = Permission(rawValue: 0x00000080)
    /// This user can read messages.
    public static let readMessages = Permission(rawValue: 0x00000400)
    /// This user can send messages.
    public static let sendMessages = Permission(rawValue: 0x00000800)
    /// This user can send tts messages.
    public static let sendTTSMessages = Permission(rawValue: 0x00001000)
    /// This user can manage messages.
    public static let manageMessages = Permission(rawValue: 0x00002000)
    /// This user can embed links.
    public static let embedLinks = Permission(rawValue: 0x00004000)
    /// This user can attach files.
    public static let attachFiles = Permission(rawValue: 0x00008000)
    /// This user read the message history.
    public static let readMessageHistory = Permission(rawValue: 0x00010000)
    /// This user can mention everyone.
    public static let mentionEveryone = Permission(rawValue: 0x00020000)
    /// This user can can add external emojis.
    public static let useExternalEmojis = Permission(rawValue: 0x00040000)
    /// This user can connect to a voice channel.
    public static let connect = Permission(rawValue: 0x00100000)
    /// This user can speak on a voice channel.
    public static let speak = Permission(rawValue: 0x00200000)
    /// This user can mute members.
    public static let muteMembers = Permission(rawValue: 0x00400000)
    /// This user can deafen members.
    public static let deafenMembers = Permission(rawValue: 0x00800000)
    /// This user can move members.
    public static let moveMembers = Permission(rawValue: 0x01000000)
    /// This user can use VAD.
    public static let useVAD = Permission(rawValue: 0x02000000)
    /// This user can change their nickname.
    public static let changeNickname = Permission(rawValue: 0x04000000)
    /// This user can manage nicknames.
    public static let manageNicknames = Permission(rawValue: 0x08000000)
    /// This user can manage roles.
    public static let manageRoles = Permission(rawValue: 0x10000000)
    /// This user can manage WebHooks
    public static let manageWebhooks = Permission(rawValue: 0x20000000)
    /// This user can manage emojis
    public static let manageEmojis = Permission(rawValue: 0x40000000)
    
    /// All the channel permissions set to true.
    public static let allChannel = Permission(rawValue: 0x33F7FC51)

    /// All voice permissions set to true
    public static let voice = Permission(rawValue: 0x3F00000)

    /// User has all permissions.
    public static let all = Permission(rawValue: Int.max >> 10)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
