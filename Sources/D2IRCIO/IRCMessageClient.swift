import D2MessageIO
import IRC
import Logging

fileprivate let log = Logger(label: "D2IRCIO.IRCMessageClient")

struct IRCMessageClient: MessageClient {
    private let ircClient: IRCClient
    
    var me: D2MessageIO.User? { nil } // TODO
    let name: String
    var guilds: [Guild]? { nil }
	var messageFetchLimit: Int? { nil }
    
    init(ircClient: IRCClient, name: String) {
        self.ircClient = ircClient
        self.name = name
    }

    func guild(for guildId: GuildID) -> Guild? {
        // TODO
        nil
    }
	
	func setPresence(_ presence: PresenceUpdate) {
        // TODO
    }
	
	func guildForChannel(_ channelId: ChannelID) -> Guild? {
        // TODO
        nil
    }

	func permissionsForUser(_ userId: UserID, in channelId: ChannelID, on guildId: GuildID) -> Permission {
        // TODO
        []
    }
	
	func addGuildMemberRole(_ roleId: RoleID, to userId: UserID, on guildId: GuildID, reason: String?, then: ClientCallback<Bool>?) {
        // TODO
        then?(false, nil)
    }

	func removeGuildMemberRole(_ roleId: RoleID, from userId: UserID, on guildId: GuildID, reason: String?, then: ClientCallback<Bool>?) {
        // TODO
        then?(false, nil)
    }
	
	func createDM(with userId: UserID, then: ClientCallback<ChannelID?>?) {
        // TODO
        then?(nil, nil)
    }

	
	func sendMessage(_ message: D2MessageIO.Message, to channelId: ChannelID, then: ClientCallback<D2MessageIO.Message?>?) {
        log.debug("Sending message '\(message.content)'")
        ircClient.sendMessage(message.usingIRCAPI)
    }
	
	func editMessage(_ id: MessageID, on channelId: ChannelID, content: String, then: ClientCallback<D2MessageIO.Message?>?) {
        // TODO
        then?(nil, nil)
    }
	
	func deleteMessage(_ id: MessageID, on channelId: ChannelID, then: ClientCallback<Bool>?) {
        // TODO
        then?(false, nil)
    }
	
	func bulkDeleteMessages(_ ids: [MessageID], on channelId: ChannelID, then: ClientCallback<Bool>?) {
        // TODO
        then?(false, nil)
    }
	
	func getMessages(for channelId: ChannelID, limit: Int, selection: MessageSelection?, then: ClientCallback<[D2MessageIO.Message]>?) {
        // TODO
        then?([], nil)
    }

	func isGuildTextChannel(_ channelId: ChannelID, then: ClientCallback<Bool>?) {
        // TODO
        then?(false, nil)
    }
	
	func isDMTextChannel(_ channelId: ChannelID, then: ClientCallback<Bool>?) {
        // TODO
        then?(false, nil)
    }
	
	func triggerTyping(on channelId: ChannelID, then: ClientCallback<Bool>?) {
        // TODO
        then?(false, nil)
    }
	
	func createReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String, then: ClientCallback<D2MessageIO.Message?>?) {
        // TODO
        then?(nil, nil)
    }
}
