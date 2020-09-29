import Utils

/// A decorator message client that uses a custom 'name' and 'me'.
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

    public func addGuildMemberRole(_ roleId: RoleID, to userId: UserID, on guildId: GuildID, reason: String?) -> Promise<Bool, Error> {
        inner.addGuildMemberRole(roleId, to: userId, on: guildId, reason: reason)
    }

    public func removeGuildMemberRole(_ roleId: RoleID, from userId: UserID, on guildId: GuildID, reason: String?) -> Promise<Bool, Error> {
        inner.removeGuildMemberRole(roleId, from: userId, on: guildId, reason: reason)
    }

    public func createDM(with userId: UserID) -> Promise<ChannelID?, Error> {
        inner.createDM(with: userId)
    }

    public func sendMessage(_ message: Message, to channelId: ChannelID) -> Promise<Message?, Error> {
        inner.sendMessage(message, to: channelId)
    }

    public func editMessage(_ id: MessageID, on channelId: ChannelID, content: String) -> Promise<Message?, Error> {
        inner.editMessage(id, on: channelId, content: content)
    }

    public func deleteMessage(_ id: MessageID, on channelId: ChannelID) -> Promise<Bool, Error> {
        inner.deleteMessage(id, on: channelId)
    }

    public func bulkDeleteMessages(_ ids: [MessageID], on channelId: ChannelID) -> Promise<Bool, Error> {
        inner.bulkDeleteMessages(ids, on: channelId)
    }

    public func getMessages(for channelId: ChannelID, limit: Int, selection: MessageSelection?) -> Promise<[Message], Error> {
        inner.getMessages(for: channelId, limit: limit, selection: selection)
    }

    public func isGuildTextChannel(_ channelId: ChannelID) -> Promise<Bool, Error> {
        inner.isGuildTextChannel(channelId)
    }

    public func isDMTextChannel(_ channelId: ChannelID) -> Promise<Bool, Error> {
        inner.isDMTextChannel(channelId)
    }

    public func triggerTyping(on channelId: ChannelID) -> Promise<Bool, Error> {
        inner.triggerTyping(on: channelId)
    }

    public func createReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) -> Promise<Message?, Error> {
        inner.createReaction(for: messageId, on: channelId, emoji: emoji)
    }

    public func createEmoji(on guildId: GuildID, name: String, image: String, roles: [RoleID]) -> Promise<Emoji?, Error> {
        inner.createEmoji(on: guildId, name: name, image: image, roles: roles)
    }

    public func deleteEmoji(from guildId: GuildID, emojiId: EmojiID) -> Promise<Bool, Error> {
        inner.deleteEmoji(from: guildId, emojiId: emojiId)
    }
}
