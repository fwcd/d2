import D2MessageIO

public struct CommandContext {
	public let client: MessageClient?
	public let registry: CommandRegistry
	public let message: Message
	public let channel: InteractiveTextChannel?
	
	public var author: User { return message.author ?? User() }
	public var guild: Guild? { return message.channelId.flatMap { client?.guildForChannel($0) } }
	
	public init(client: MessageClient?, registry: CommandRegistry, message: Message) {
		self.client = client
		self.registry = registry
		self.message = message
		
		channel = client.flatMap { c in message.channelId.map { InteractiveTextChannel(id: $0, client: c) } }
	}
}
