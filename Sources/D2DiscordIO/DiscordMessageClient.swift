import D2MessageIO
import Logging
import SwiftDiscord

fileprivate let log = Logger(label: "D2DiscordIO.DiscordMessageClient")

struct DiscordMessageClient: MessageClient {
	private let client: DiscordClient
	
	var name: String { return discordClientName }
	var me: User? { return client.user?.usingMessageIO }
	
	init(client: DiscordClient) {
		self.client = client
	}
	
	func guild(for guildId: D2MessageIO.GuildID) -> Guild? {
		return client.guilds[guildId.usingDiscordAPI]?.usingMessageIO
	}
	
	func setPresence(_ presence: PresenceUpdate) {
		client.setPresence(presence.usingDiscordAPI)
	}
	
	func guildForChannel(_ channelId: D2MessageIO.ChannelID) -> Guild? {
		return client.guildForChannel(channelId.usingDiscordAPI)?.usingMessageIO
	}
	
	func permissionsForUser(_ userId: D2MessageIO.UserID, in channelId: D2MessageIO.ChannelID, on guildId: D2MessageIO.GuildID) -> Permission {
		// Partly based on MIT-licensed code from https://github.com/nuclearace/SwiftDiscord/blob/9e2be352a580b1c9cf92149be335f61192b85bdb/Sources/SwiftDiscord/Guild/DiscordGuildChannel.swift#L91-L136
		// Copyright (c) 2016 Erik Little

		guard let guild = client.guildForChannel(channelId.usingDiscordAPI),
				let channel = guild.channels[channelId.usingDiscordAPI],
				let everybodyRole = guild.roles[guildId.usingDiscordAPI] else {
			log.warning("Could not check Discord permission of user \(userId) in channel \(channelId)!")
			return []
		}
		var permissions = everybodyRole.permissions

		if let everybodyOverwrite = channel.permissionOverwrites[guildId.usingDiscordAPI] {
			permissions.subtract(everybodyOverwrite.deny)
			permissions.formUnion(everybodyOverwrite.allow)
		}
		
		if !permissions.contains(.sendMessages) {
			// If they can't send messages, they automatically lose some permissions
            permissions.subtract([.sendTTSMessages, .mentionEveryone, .attachFiles, .embedLinks])
		}

		if !permissions.contains(.readMessages) {
			// If they can't read, they lose all channel based permissions
			permissions.subtract(.allChannel)
		}

		if channel is DiscordGuildTextChannel {
            // Text channels don't have voice permissions.
            permissions.subtract(.voice)
        }

		return permissions.usingMessageIO
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
	
	func createDM(with userId: D2MessageIO.UserID, then: ClientCallback<D2MessageIO.ChannelID?>?) {
		client.createDM(with: userId.usingDiscordAPI) {
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
	
	func deleteMessage(_ id: D2MessageIO.MessageID, on channelId: D2MessageIO.ChannelID, then: ClientCallback<Bool>?) {
		client.deleteMessage(id.usingDiscordAPI, on: channelId.usingDiscordAPI) {
			then?($0, $1)
		}
	}

	func bulkDeleteMessages(_ ids: [D2MessageIO.MessageID], on channelId: D2MessageIO.ChannelID, then: ClientCallback<Bool>?) {
		client.bulkDeleteMessages(ids.map { $0.usingDiscordAPI }, on: channelId.usingDiscordAPI) {
			then?($0, $1)
		}
	}

	func getMessages(for channelId: D2MessageIO.ChannelID, limit: Int, then: ClientCallback<[Message]>?) {
		client.getMessages(for: channelId.usingDiscordAPI, limit: limit) {
			then?($0.map { $0.usingMessageIO }, $1)
		}
	}

	func isGuildTextChannel(_ channelId: D2MessageIO.ChannelID, then: ClientCallback<Bool>?) {
		client.getChannel(channelId.usingDiscordAPI) {
			then?($0.map { $0 is DiscordGuildTextChannel } ?? false, $1)
		}
	}
	
	func isDMTextChannel(_ channelId: D2MessageIO.ChannelID, then: ClientCallback<Bool>?) {
		client.getChannel(channelId.usingDiscordAPI) {
			then?($0.map { $0 is DiscordDMChannel || $0 is DiscordGroupDMChannel } ?? false, $1)
		}
	}

	func triggerTyping(on channelId: D2MessageIO.ChannelID, then: ClientCallback<Bool>?) {
		client.triggerTyping(on: channelId.usingDiscordAPI) {
			then?($0, $1)
		}
	}
	
	func createReaction(for messageId: D2MessageIO.MessageID, on channelId: D2MessageIO.ChannelID, emoji: String, then: ClientCallback<Message?>?) {
		client.createReaction(for: messageId.usingDiscordAPI, on: channelId.usingDiscordAPI, emoji: emoji) {
			then?($0?.usingMessageIO, $1)
		}
	}
}
