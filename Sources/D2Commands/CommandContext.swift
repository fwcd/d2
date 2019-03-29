import SwiftDiscord

public struct CommandContext {
	public let guild: DiscordGuild?
	public let registry: CommandRegistry
	public let message: DiscordMessage
	
	public var author: DiscordUser { return message.author }
	public var channel: DiscordTextChannel? { return message.channel }
	public var client: DiscordClient? { return message.client }
	
	init(guild: DiscordGuild?, registry: CommandRegistry, message: DiscordMessage) {
		self.guild = guild
		self.registry = registry
		self.message = message
	}
}
