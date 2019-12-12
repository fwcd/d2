/**
 * A wrapper around a channel ID holding a
 * client reference.
 */
public struct InteractiveTextChannel {
	public let id: ChannelID
	private let client: MessageClient
	
	public init(id: ChannelID, client: MessageClient) {
		self.id = id
		self.client = client
	}
	
	public func send(_ message: Message, then: (ClientCallback<Message?>)? = nil) {
		client.sendMessage(message, to: id, then: then)
	}
	
	public func triggerTyping(then: (ClientCallback<Bool>)? = nil) {
		client.triggerTyping(on: id, then: then)
	}
}
