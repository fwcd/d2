import D2MessageIO
import Emoji
import Telegrammer
import Logging

fileprivate let log = Logger(label: "D2TelegramIO.TelegramMessageClient")

struct TelegramMessageClient: MessageClient {
    private let bot: Bot
    
    var me: D2MessageIO.User? { nil } // TODO
    var name: String { telegramClientName }
    var guilds: [Guild]? { nil }
    
    init(bot: Bot) {
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
    
    private func flatten(embed: Embed) -> String {
        let lines: [String?] = [
            embed.title.flatMap { title in embed.url.map { "[\(title)](\($0.absoluteString))" } ?? title },
            embed.description
        ] + embed.fields.flatMap { ["**\($0.name)**", $0.value] } + [
            embed.footer?.text
        ]
        return lines
            .compactMap { $0 }
            .joined(separator: "\n")
    }
	
	func sendMessage(_ message: D2MessageIO.Message, to channelId: ChannelID, then: ClientCallback<D2MessageIO.Message?>?) {
        let text = [message.content, message.embed.map(flatten(embed:))]
            .compactMap { $0?.nilIfEmpty }
            .joined(separator: "\n")
            .emojiUnescapedString
        log.debug("Sending message '\(text)'")

        do {
            try bot.sendMessage(params: .init(chatId: .chat(channelId.usingTelegramAPI), text: text, parseMode: .markdown)).whenComplete {
                do {
                    then?(try $0.get().usingMessageIO, nil)
                } catch {
                    log.warning("Could not send message to Telegram: \(error)")
                    then?(nil, nil)
                }
            }
        } catch {
            log.warning("Could not send message to Telegram: \(error)")
            then?(nil, nil)
        }
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
