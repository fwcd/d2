import SwiftDiscord

struct CommandContext {
	let guild: DiscordGuild?
	let registry: CommandRegistry
	let message: DiscordMessage
	
	var author: DiscordUser { return message.author }
	var channel: DiscordTextChannel? { return message.channel }
	var client: DiscordClient? { return message.client }
}
