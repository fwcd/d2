import Foundation

public typealias ClientCallback<T> = (T, HTTPURLResponse?) -> Void

public protocol MessageClient {
	var user: User { get } // Me
	
	func setPresence(_ presence: PresenceUpdate)
	
	func guildForChannel(_ channelId: ChannelID) -> Guild?
	
	func createDM(with me: UserID, user: UserID, then: @escaping ClientCallback<ChannelID>)
	
	func sendMessage(_ message: Message, to channelId: ChannelID, then: @escaping ClientCallback<Message?>)
	
	func editMessage(_ id: MessageID, on channelId: ChannelID, content: String, then: @escaping ClientCallback<Message?>)
	
	func getMessages(for channelId: ChannelID, limit: Int, then: @escaping ClientCallback<[Message]>)
}
