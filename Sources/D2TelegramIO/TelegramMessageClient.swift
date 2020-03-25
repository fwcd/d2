import D2MessageIO
import TelegramBotSDK

struct TelegramMessageClient: MessageClient {
    private let bot: TelegramBot
    
    var me: D2MessageIO.User? { nil } // TODO
    var name: String { telegramClientName }
    
    init(bot: TelegramBot) {
        self.bot = bot
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
        // TODO
        then?(nil, nil)
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
	
	func getMessages(for channelId: ChannelID, limit: Int, then: ClientCallback<[D2MessageIO.Message]>?) {
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
