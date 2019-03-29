import SwiftDiscord

func mentionedUsers(in message: DiscordMessage, on guild: DiscordGuild?) -> [DiscordUser] {
	if message.mentionEveryone {
		return everyone(on: guild)
	} else {
		return message.mentions + users(with: message.mentionRoles, on: guild)
	}
}

private func everyone(on guild: DiscordGuild?) -> [DiscordUser] {
	return guild?.members.map { $0.value.user } ?? []
}

private func users(with roles: [RoleID], on guild: DiscordGuild?) -> [DiscordUser] {
	return roles.flatMap { role in
		guild?.members
			.map { $0.value }
			.filter { $0.roleIds.contains(role) }
			.map { $0.user }
			?? []
	}
}
