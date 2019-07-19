import SwiftDiscord
import D2MessageIO

// FROM Discord conversions

extension DiscordGuild {
	var usingMessageIO: Guild {
		return Guild(
			id: id.usingMessageIO,
			large: large,
			joinedAt: joinedAt,
			splash: splash,
			unavailable: unavailable,
			description: description,
			channels: Dictionary(uniqueKeysWithValues: channels.map { ($0.usingMessageIO, $1.usingMessageIO) })
		)
	}
}

extension DiscordGuildChannel {
	var usingMessageIO: Guild.GuildChannel {
		return Guild.GuildChannel(
			guildId: guildId.usingMessageIO,
			name: name,
			parentId: parentId?.usingMessageIO,
			position: position,
			permissionOverwrites: Dictionary(uniqueKeysWithValues: permissionOverwrites.map { ($0.usingMessageIO, $1.usingMessageIO) })
		)
	}
}

extension DiscordPermissionOverwrite {
	var usingMessageIO: Guild.GuildChannel.PermissionOverwrite {
		return Guild.GuildChannel.PermissionOverwrite(
			id: id.usingMessageIO,
			type: type.usingMessageIO
		)
	}
}

extension DiscordPermissionOverwriteType {
	var usingMessageIO: Guild.GuildChannel.PermissionOverwrite.PermissionOverwriteType {
		switch self {
			case .role: return .role
			case .member: return .member
		}
	}
}
