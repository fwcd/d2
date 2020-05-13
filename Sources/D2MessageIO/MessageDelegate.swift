public protocol MessageDelegate {
	func on(connect connected: Bool, client: MessageClient)
	
	func on(receivePresenceUpdate presence: Presence, client: MessageClient)

	func on(createMessage message: Message, client: MessageClient)

	func on(createGuild guild: Guild, client: MessageClient)
}

public extension MessageDelegate {
	func on(connect connected: Bool, client: MessageClient) {}

	func on(receivePresenceUpdate presence: Presence, client: MessageClient) {}

	func on(createMessage message: Message, client: MessageClient) {}

	func on(createGuild guild: Guild, client: MessageClient) {}
}
