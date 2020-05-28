/**
 * A decorator message client that uses a custom 'name' and 'me'.
 */
public struct OverlayMessageClient: MessageClient {
    private let inner: MessageClient

	public let name: String
	public let me: User?
    public var guilds: [Guild]? { inner.guilds }
	public var messageFetchLimit: Int? { inner.messageFetchLimit }
    
    public init(inner: MessageClient, name: String, me: User? = nil) {
        self.inner = inner
        self.name = name
        self.me = me
    }
	
	public func guild(for guildId: GuildID) -> Guild? {
        inner.guild(for: guildId)
    }
	
	public func setPresence(_ presence: PresenceUpdate) {
        inner.setPresence(presence)
    }
	
	public func guildForChannel(_ channelId: ChannelID) -> Guild? {
        inner.guildForChannel(channelId)
    }

	public func permissionsForUser(_ userId: UserID, in channelId: ChannelID, on guildId: GuildID) -> Permission {
        inner.permissionsForUser(userId, in: channelId, on: guildId)
    }
	
	public func addGuildMemberRole(_ roleId: RoleID, to userId: UserID, on guildId: GuildID, reason: String?, then: ClientCallback<Bool>?) {
        inner.addGuildMemberRole(roleId, to: userId, on: guildId, reason: reason, then: then)
    }

	public func removeGuildMemberRole(_ roleId: RoleID, from userId: UserID, on guildId: GuildID, reason: String?, then: ClientCallback<Bool>?) {
        inner.removeGuildMemberRole(roleId, from: userId, on: guildId, reason: reason, then: then)
    }
	
	public func createDM(with userId: UserID, then: ClientCallback<ChannelID?>?) {
        inner.createDM(with: userId, then: then)
    }
	
	public func sendMessage(_ message: Message, to channelId: ChannelID, then: ClientCallback<Message?>?) {
        inner.sendMessage(message, to: channelId, then: then)
    }
	
	public func editMessage(_ id: MessageID, on channelId: ChannelID, content: String, then: ClientCallback<Message?>?) {
        inner.editMessage(id, on: channelId, content: content, then: then)
    }
	
	public func deleteMessage(_ id: MessageID, on channelId: ChannelID, then: ClientCallback<Bool>?) {
        inner.deleteMessage(id, on: channelId, then: then)
    }
	
	public func bulkDeleteMessages(_ ids: [MessageID], on channelId: ChannelID, then: ClientCallback<Bool>?) {
        inner.bulkDeleteMessages(ids, on: channelId, then: then)
    }
	
	public func getMessages(for channelId: ChannelID, limit: Int, selection: MessageSelection?, then: ClientCallback<[Message]>?) {
        inner.getMessages(for: channelId, limit: limit, selection: selection, then: then)
    }

	public func isGuildTextChannel(_ channelId: ChannelID, then: ClientCallback<Bool>?) {
        inner.isGuildTextChannel(channelId, then: then)
    }
	
	public func isDMTextChannel(_ channelId: ChannelID, then: ClientCallback<Bool>?) {
        inner.isDMTextChannel(channelId, then: then)
    }
	
	public func triggerTyping(on channelId: ChannelID, then: ClientCallback<Bool>?) {
        inner.triggerTyping(on: channelId, then: then)
    }
	
	public func createReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String, then: ClientCallback<Message?>?) {
        inner.createReaction(for: messageId, on: channelId, emoji: emoji, then: then)
    }
}
