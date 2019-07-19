import Foundation

public typealias ClientCallback<T> = (T, HTTPURLResponse?) -> Void

public protocol MessageClient {
	func setPresence(_ presence: PresenceUpdate)
	
	func guildForChannel(_ channelID: ChannelID) -> Guild?
	
	func sendMessage(_ message: Message, to channelID: ChannelID, then: @escaping ClientCallback<Message?>)
	
	func editMessage(_ id: MessageID, on channelID: ChannelID, content: String, then: @escaping ClientCallback<Message?>)
	
	func getMessages(for channelID: ChannelID, limit: Int, then: @escaping ClientCallback<[Message]>)
}
