import D2MessageIO

public struct CommandContext {
	public let guild: Guild?
	public let registry: CommandRegistry
	public let message: Message
	
	public var author: User { return message.author }
	public var channel: TextChannel? { return message.channel }
	public var client: MessageClient? { return message.client }
	
	public init(guild: Guild?, registry: CommandRegistry, message: Message) {
		self.guild = guild
		self.registry = registry
		self.message = message
	}
}
