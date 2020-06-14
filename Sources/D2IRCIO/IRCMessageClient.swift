import D2MessageIO
import Emoji
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

    private func flatten(embed: Embed) -> String {
        let lines: [String?] = [
            embed.title.flatMap { title in embed.url.map { "[\(title)](\($0.absoluteString))" } ?? title },
            embed.description
        ] + embed.fields.flatMap { ["**\($0.name)**", $0.value] } + [
            embed.footer?.text
        ]
        return lines
            .compactMap { $0 }
            .joined(separator: ", ")
    }
	
	func sendMessage(_ message: D2MessageIO.Message, to channelId: ChannelID, then: ClientCallback<D2MessageIO.Message?>?) {
        log.debug("Sending message '\(message.content)'")

        let text = [message.content, message.embed.map(flatten(embed:))]
            .compactMap { $0?.nilIfEmpty }
            .joined(separator: ", ")
            .emojiUnescapedString

        guard let channelName = IRCChannelName(channelId.value) else {
            log.warning("Could not convert \(channelId.value) (maybe it is missing a leading '#'?)")
            return
        }

        ircClient.send(.PRIVMSG([.channel(channelName)], text))
        // TODO: Handle client callback here
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
