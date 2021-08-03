import Discord
import D2MessageIO

// FROM Discord conversions

extension DiscordGuild: MessageIOConvertible {
    public var usingMessageIO: Guild {
        Guild(
            id: id.usingMessageIO,
            ownerId: ownerId?.usingMessageIO,
            region: region,
            large: large ?? false,
            name: name ?? "",
            joinedAt: joinedAt,
            splash: splash ?? "",
            unavailable: unavailable ?? false,
            description: description,
            mfaLevel: mfaLevel,
            verificationLevel: verificationLevel,
            widgetEnabled: widgetEnabled ?? false,
            widgetChannelId: widgetChannelId?.usingMessageIO,
            icon: icon,
            members: Dictionary(uniqueKeysWithValues: members?.map { (k, v) in (k.usingMessageIO, v.usingMessageIO(in: id.usingMessageIO)) } ?? []),
            roles: roles?.usingMessageIO ?? [:],
            presences: presences?.usingMessageIO ?? [:],
            voiceStates: voiceStates?.usingMessageIO ?? [:],
            emojis: Dictionary(uniqueKeysWithValues: emojis?.compactMap { (k, v) in k.map { ($0.usingMessageIO, v.usingMessageIO) } } ?? []),
            channels: channels?.usingMessageIO ?? [:]
        )
    }
}

extension DiscordChannel: MessageIOConvertible {
    public var usingMessageIO: Guild.Channel {
        Guild.Channel(
            id: id.usingMessageIO,
            guildId: guildId?.usingMessageIO,
            name: name ?? "",
            topic: topic,
            parentId: parentId?.usingMessageIO,
            position: position ?? 0,
            type: type.usingMessageIO,
            permissionOverwrites: permissionOverwrites?.usingMessageIO ?? [:]
        )
    }
}

extension DiscordChannelType: MessageIOConvertible {
    public var usingMessageIO: Guild.Channel.ChannelType {
        switch self {
            case .text: return .text
            case .voice: return .voice
            case .category: return .category
            default: return .init(rawValue: rawValue)
        }
    }
}

extension DiscordPermissionOverwrite: MessageIOConvertible {
    public var usingMessageIO: Guild.Channel.PermissionOverwrite {
        Guild.Channel.PermissionOverwrite(
            id: id.usingMessageIO,
            type: type.usingMessageIO
        )
    }
}

extension DiscordPermissionOverwriteType: MessageIOConvertible {
    public var usingMessageIO: Guild.Channel.PermissionOverwrite.PermissionOverwriteType {
        switch self {
            case .role: return .role
            case .member: return .member
            default: return .init(rawValue: rawValue)
        }
    }
}

extension DiscordGuildMember {
    public func usingMessageIO(in guildId: D2MessageIO.GuildID) -> Guild.Member {
        return Guild.Member(
            guildId: guildId,
            joinedAt: joinedAt,
            user: user.usingMessageIO,
            deaf: deaf,
            mute: mute,
            nick: nick,
            roleIds: roleIds.usingMessageIO
        )
    }
}
