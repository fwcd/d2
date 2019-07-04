public protocol MessageClient {
	func setPresence(_ presence: PresenceUpdate)
	
	func guildForChannel(_ channelID: ChannelID)
	
	func sendMessage(_ message: Message, then: (Message) -> Void)
	
	func editMessage(_ id: MessageID, on channelID: ChannelID, content: String, then: (Message) -> Void)
	
	func getMessages(for channelID: ChannelID, limit: Int)
}
