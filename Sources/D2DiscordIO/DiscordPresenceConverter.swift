import Foundation
import D2MessageIO
import SwiftDiscord

// FROM Discord conversions

extension DiscordPresence: MessageIOConvertible {
	public var usingMessageIO: Presence {
		return Presence(
			guildId: guildId.usingMessageIO,
			user: user.usingMessageIO,
			game: game?.usingMessageIO,
			activities: activities.usingMessageIO,
			nick: nick,
			roles: roles,
			status: status.usingMessageIO
		)
	}
}

extension DiscordActivity: MessageIOConvertible {
	public var usingMessageIO: Presence.Activity {
		return Presence.Activity(
			name: name,
			assets: assets?.usingMessageIO,
			details: details,
			party: party?.usingMessageIO,
			state: state,
			timestamps: timestamps?.usingMessageIO,
			type: type.usingMessageIO,
			url: url
		)
	}
}

extension DiscordActivityAssets: MessageIOConvertible {
	public var usingMessageIO: Presence.Activity.Assets {
		return Presence.Activity.Assets(
			largeImage: largeImage,
			largeText: largeText,
			smallImage: smallImage,
			smallText: smallText
		)
	}
}

extension DiscordPresenceStatus: MessageIOConvertible {
	public var usingMessageIO: Presence.Status {
		switch self {
			case .idle: return .idle
			case .offline: return .offline
			case .online: return .online
			case .doNotDisturb: return .doNotDisturb
		}
	}
}

extension DiscordParty: MessageIOConvertible {
	public var usingMessageIO: Presence.Activity.Party {
		return Presence.Activity.Party(
			id: id,
			sizes: sizes
		)
	}
}

extension DiscordActivityTimestamps: MessageIOConvertible {
	public var usingMessageIO: Presence.Activity.Timestamps {
		return Presence.Activity.Timestamps(
			start: start.map { Date(timeIntervalSince1970: Double($0) / 1000) },
			end: end.map { Date(timeIntervalSince1970: Double($0) / 1000) }
		)
	}
}

extension DiscordActivityType: MessageIOConvertible {
	public var usingMessageIO: Presence.Activity.ActivityType {
		switch self {
			case .game: return .game
			case .stream: return .stream
			case .listening: return .listening
		}
	}
}

// TO Discord conversions

extension PresenceUpdate: DiscordAPIConvertible {
	public var usingDiscordAPI: DiscordPresenceUpdate {
		return DiscordPresenceUpdate(
			game: game?.usingDiscordAPI,
			status: status.usingDiscordAPI,
			afkSince: afkSince
		)
	}
}

extension Presence.Status: DiscordAPIConvertible {
	public var usingDiscordAPI: DiscordPresenceStatus {
		switch self {
			case .idle: return .idle
			case .offline: return .offline
			case .online: return .online
			case .doNotDisturb: return .doNotDisturb
		}
	}
}

extension Presence.Activity: DiscordAPIConvertible {
	public var usingDiscordAPI: DiscordActivity {
		return DiscordActivity(name: name, type: type.usingDiscordAPI)
	}
}

extension Presence.Activity.ActivityType: DiscordAPIConvertible {
	public var usingDiscordAPI: DiscordActivityType {
		switch self {
			case .game: return .game
			case .stream: return .stream
			case .listening: return .listening
		}
	}
}
