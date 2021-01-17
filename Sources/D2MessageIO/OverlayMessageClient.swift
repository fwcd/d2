import Foundation
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

    public func avatarUrlForUser(_ userId: UserID, with avatarId: String, size: Int, preferredExtension: String?) -> URL? {
        inner.avatarUrlForUser(userId, with: avatarId, size: size, preferredExtension: preferredExtension)
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

    public func deleteOwnReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) -> Promise<Bool, Error> {
        inner.deleteOwnReaction(for: messageId, on: channelId, emoji: emoji)
    }

    public func deleteUserReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String, by userId: UserID) -> Promise<Bool, Error> {
        inner.deleteUserReaction(for: messageId, on: channelId, emoji: emoji, by: userId)
    }

    public func createEmoji(on guildId: GuildID, name: String, image: String, roles: [RoleID]) -> Promise<Emoji?, Error> {
        inner.createEmoji(on: guildId, name: name, image: image, roles: roles)
    }

    public func deleteEmoji(from guildId: GuildID, emojiId: EmojiID) -> Promise<Bool, Error> {
        inner.deleteEmoji(from: guildId, emojiId: emojiId)
    }

    public func getMIOCommands() -> Promise<[MIOCommand], Error> {
        inner.getMIOCommands()
    }

    public func createMIOCommand(name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, Error> {
        inner.createMIOCommand(name: name, description: description, options: options)
    }

    public func editMIOCommand(_ commandId: MIOCommandID, name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, Error> {
        inner.editMIOCommand(commandId, name: name, description: description, options: options)
    }

    public func deleteMIOCommand(_ commandId: MIOCommandID) -> Promise<Bool, Error> {
        inner.deleteMIOCommand(commandId)
    }

    public func getMIOCommands(on guildId: GuildID) -> Promise<[MIOCommand], Error> {
        inner.getMIOCommands(on: guildId)
    }

    public func createMIOCommand(on guildId: GuildID, name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, Error> {
        inner.createMIOCommand(on: guildId, name: name, description: description, options: options)
    }

    public func editMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID, name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, Error> {
        inner.editMIOCommand(commandId, on: guildId, name: name, description: description, options: options)
    }

    public func deleteMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID) -> Promise<Bool, Error> {
        inner.deleteMIOCommand(commandId, on: guildId)
    }

    public func createInteractionResponse(for interactionId: InteractionID, token: String, response: InteractionResponse) -> Promise<Bool, Error> {
        inner.createInteractionResponse(for: interactionId, token: token, response: response)
    }
}
