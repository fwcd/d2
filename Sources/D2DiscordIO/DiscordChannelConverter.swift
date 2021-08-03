import Discord
import D2MessageIO

// FROM Discord conversions

extension DiscordChannel: MessageIOConvertible {
    public var usingMessageIO: Channel {
        Channel(
            id: id.usingMessageIO,
            guildId: guildId?.usingMessageIO,
            name: name ?? "",
            topic: topic,
            parentId: parentId?.usingMessageIO,
            position: position ?? 0,
            type: type.usingMessageIO,
            threadMetadata: threadMetadata.usingMessageIO,
            permissionOverwrites: permissionOverwrites?.usingMessageIO ?? [:]
        )
    }
}

extension DiscordChannelType: MessageIOConvertible {
    public var usingMessageIO: Channel.ChannelType {
        switch self {
            case .text: return .text
            case .dm: return .dm
            case .voice: return .voice
            case .groupDM: return .groupDM
            case .category: return .category
            case .news: return .news
            case .store: return .store
            case .newsThread: return .newsThread
            case .publicThread: return .publicThread
            case .privateThread: return .privateThread
            case .stageVoice: return .stageVoice
            default: return .init(rawValue: rawValue)
        }
    }
}

extension DiscordPermissionOverwrite: MessageIOConvertible {
    public var usingMessageIO: Channel.PermissionOverwrite {
        Channel.PermissionOverwrite(
            id: id.usingMessageIO,
            type: type.usingMessageIO
        )
    }
}

extension DiscordPermissionOverwriteType: MessageIOConvertible {
    public var usingMessageIO: Channel.PermissionOverwrite.PermissionOverwriteType {
        switch self {
            case .role: return .role
            case .member: return .member
            default: return .init(rawValue: rawValue)
        }
    }
}

extension DiscordThreadMetadata: MessageIOConvertible {
    public var usingMessageIO: Channel.ThreadMetadata {
        Channel.ThreadMetadata(
            archived: archived,
            autoArchiveDuration: autoArchiveDuration,
            archiveTimestamp: archiveTimestamp,
            locked: locked
        )
    }
}
