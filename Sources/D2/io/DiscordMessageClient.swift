import D2MessageIO
import SwiftDiscord

struct DiscordMessageClient: MessageClient {
	private let client: DiscordClient
	var me: User? { return client.user?.usingMessageIO }
	
	init(client: DiscordClient) {
		self.client = client
	}
	
	func setPresence(_ presence: PresenceUpdate) {
		client.setPresence(presence.usingDiscordAPI)
	}
	
	func guildForChannel(_ channelId: D2MessageIO.ChannelID) -> Guild? {
		return client.guildForChannel(channelId.usingDiscordAPI)?.usingMessageIO
	}
	
	func addGuildMemberRole(_ roleId: D2MessageIO.RoleID, to userId: D2MessageIO.UserID, on guildId: D2MessageIO.GuildID, reason: String?, then: ClientCallback<Bool>?) {
		client.addGuildMemberRole(roleId.usingDiscordAPI, to: userId.usingDiscordAPI, on: guildId.usingDiscordAPI) {
			then?($0, $1)
		}
	}
	
	func removeGuildMemberRole(_ roleId: D2MessageIO.RoleID, from userId: D2MessageIO.UserID, on guildId: D2MessageIO.GuildID, reason: String?, then: ClientCallback<Bool>?) {
		client.removeGuildMemberRole(roleId.usingDiscordAPI, from: userId.usingDiscordAPI, on: guildId.usingDiscordAPI) {
			then?($0, $1)
		}
	}
	
	func createDM(with user: D2MessageIO.UserID, then: ClientCallback<D2MessageIO.ChannelID>?) {
		client.createDM(with: user) {
			then?($0?.id.usingMessageIO, $1)
		}
	}
	
	func sendMessage(_ message: Message, to channelId: D2MessageIO.ChannelID, then: ClientCallback<Message?>?) {
		client.sendMessage(message.usingDiscordAPI, to: channelId.usingDiscordAPI) {
			then?($0?.usingMessageIO, $1)
		}
	}
	
	func editMessage(_ id: D2MessageIO.MessageID, on channelId: D2MessageIO.ChannelID, content: String, then: ClientCallback<Message?>?) {
		client.editMessage(id.usingDiscordAPI, on: channelId.usingDiscordAPI, content: content) {
			then?($0?.usingMessageIO, $1)
		}
	}
	
	func getMessages(for channelId: D2MessageIO.ChannelID, limit: Int, then: ClientCallback<[Message]>?) {
		client.getMessages(for: channelId.usingDiscordAPI, limit: limit) {
			then?($0.map { $0.usingMessageIO }, $1)
		}
	}

	func triggerTyping(on channelId: D2MessageIO.ChannelID, then: ClientCallback<Bool>?) {
		client.triggerTyping(on: channelId.usingDiscordAPI) {
			then?($0, $1)
		}
	}
	
	func createReaction(for messageId: D2MessageIO.MessageID, on channelId: D2MessageIO.ChannelID, emoji: String, then: ClientCallback<Message?>?) {
		then?($0?.usingMessageIO, $1)
	}
}
