import D2MessageIO
import SwiftDiscord

struct DiscordMessageClient: MessageClient {
	private let client: DiscordClient
	var user: User { return client.user.usingMessageIO }
	
	init(client: DiscordClient) {
		self.client = client
	}
	
	func setPresence(_ presence: PresenceUpdate) {
		client.setPresence(presence.usingDiscordAPI)
	}
	
	func guildForChannel(_ channelId: D2MessageIO.ChannelID) -> Guild? {
		return client.guildForChannel(channelId.usingDiscordAPI)?.usingMessageIO
	}
	
	func sendMessage(_ message: Message, to channelId: D2MessageIO.ChannelID, then: @escaping ClientCallback<Message?>) {
		client.sendMessage(message.usingDiscordAPI, to: channelId.usingDiscordAPI) {
			then($0?.usingMessageIO, $1)
		}
	}
	
	func editMessage(_ id: D2MessageIO.MessageID, on channelId: D2MessageIO.ChannelID, content: String, then: @escaping ClientCallback<Message?>) {
		client.editMessage(id.usingDiscordAPI, on: channelId.usingDiscordAPI, content: content) {
			then($0?.usingMessageIO, $1)
		}
	}
	
	func getMessages(for channelId: D2MessageIO.ChannelID, limit: Int, then: @escaping ClientCallback<[Message]>) {
		client.getMessages(for: channelId.usingDiscordAPI, limit: limit) {
			then($0.map { $0.usingMessageIO }, $1)
		}
	}
}
