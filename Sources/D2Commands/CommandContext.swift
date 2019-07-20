import D2MessageIO

public struct CommandContext {
	public let client: MessageClient?
	public let registry: CommandRegistry
	public let message: Message
	
	public var author: User { return message.author }
	public var channel: TextChannel? { return message.channel }
	public var guild: Guild? { return client?.guildForChannel(message.channelId) }
	
	public init(client: MessageClient?, registry: CommandRegistry, message: Message) {
		self.client = client
		self.registry = registry
		self.message = message
	}
}
