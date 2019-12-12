import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public typealias ClientCallback<T> = (T, HTTPURLResponse?) -> Void

fileprivate func defaultCallback<T>(_ dummy: T, error: HTTPURLResponse?) {
	if let err = error {
		print(err)
	}
}

public protocol MessageClient {
	var me: User { get } // Me
	
	func setPresence(_ presence: PresenceUpdate)
	
	func guildForChannel(_ channelId: ChannelID) -> Guild?
	
	func createDM(with user: UserID, then: @escaping ClientCallback<ChannelID>)
	
	func sendMessage(_ message: Message, to channelId: ChannelID, then: @escaping ClientCallback<Message?>)
	
	func editMessage(_ id: MessageID, on channelId: ChannelID, content: String, then: @escaping ClientCallback<Message?>)
	
	func getMessages(for channelId: ChannelID, limit: Int, then: @escaping ClientCallback<[Message]>)
}

public extension MessageClient {
	func createDM(with user: UserID) {
		createDM(with: user, then: defaultCallback)
	}
	
	func sendMessage(_ message: Message, to channelId: ChannelID) {
		sendMessage(message, to: channelId, then: defaultCallback)
	}
	
	func editMessage(_ id: MessageID, on channelId: ChannelID, content: String) {
		editMessage(id, on: channelId, content: content, then: defaultCallback)
	}
	
	func getMessages(for channelId: ChannelID, limit: Int) {
		getMessages(for: channelId, limit: limit, then: defaultCallback)
	}
}
