import D2MessageIO
import SwiftDiscord

// TO Discord conversions

extension PresenceUpdate {
	var usingDiscordAPI: DiscordPresenceUpdate {
		return DiscordPresenceUpdate(
			game: activity?.usingDiscordAPI,
			status: status.usingDiscordAPI,
			afkSince: afkSince
		)
	}
}

extension PresenceUpdate.PresenceStatus {
	var usingDiscordAPI: DiscordPresenceStatus {
		switch self {
			case .idle: return .idle
			case .offline: return .offline
			case .online: return .online
			case .doNotDisturb: return .doNotDisturb
		}
	}
}

extension PresenceUpdate.Activity {
	var usingDiscordAPI: DiscordActivity {
		return DiscordActivity(name: name, type: type.usingDiscordAPI)
	}
}

extension PresenceUpdate.Activity.ActivityType {
	var usingDiscordAPI: DiscordActivityType {
		switch self {
			case .game: return .game
			case .stream: return .stream
			case .listening: return .listening
		}
	}
}
