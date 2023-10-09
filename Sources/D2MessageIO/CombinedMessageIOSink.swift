import Foundation
import Utils
import Logging

fileprivate let log = Logger(label: "D2MessageIO.CombinedMessageIOSink")

/// A MessageIOSink that combines multiple clients and
/// dispatches requests dynamically based on the ID's client name.
public class CombinedMessageIOSink: MessageIOSink {
    private var clients: [String: any MessageIOSink] = [:]

    private let mioCommandClientName: String?
    private var mioCommandClient: (any MessageIOSink)? { mioCommandClientName.flatMap { clients[$0] } }

    public var me: User? { nil }
    public var name: String { "Combined" }
    public var guilds: [Guild]? { clients.values.flatMap { $0.guilds ?? [] } }
    public var messageFetchLimit: Int? { clients.values.compactMap { $0.messageFetchLimit }.min() }

    // TODO: Support more than one client for global MIO commands
    public init(mioCommandClientName: String? = nil) {
        self.mioCommandClientName = mioCommandClientName
    }

    @discardableResult
    public func register(client: any MessageIOSink) -> any MessageIOSink {
        clients[client.name] = client
        return OverlayMessageIOSink(inner: self, name: client.name, me: client.me)
    }

    private func withClient<T>(of id: ID, _ action: (any MessageIOSink) throws -> T?) rethrows -> T? {
        if let client = clients[id.clientName] {
            return try action(client)
        } else {
            log.warning("Could not find client with name `\(id.clientName)`. This is a bug and might result in unhandled callbacks.")
            return nil
        }
    }

    public func guild(for guildId: GuildID) -> Guild? {
        withClient(of: guildId) { $0.guild(for: guildId) }
    }

    public func channel(for channelId: ChannelID) -> Channel? {
        withClient(of: channelId) { $0.channel(for: channelId) }
    }

    public func setPresence(_ presence: PresenceUpdate) {
        for client in clients.values {
            client.setPresence(presence)
        }
    }

    public func guildForChannel(_ channelId: ChannelID) -> Guild? {
        withClient(of: channelId) { $0.guildForChannel(channelId) }
    }

    public func permissionsForUser(_ userId: UserID, in channelId: ChannelID, on guildId: GuildID) -> Permissions {
        withClient(of: channelId) { $0.permissionsForUser(userId, in: channelId, on: guildId) } ?? []
    }

    public func avatarUrlForUser(_ userId: UserID, with avatarId: String, size: Int, preferredExtension: String?) -> URL? {
        withClient(of: userId) { $0.avatarUrlForUser(userId, with: avatarId, size: size, preferredExtension: preferredExtension) }
    }

    public func addGuildMemberRole(_ roleId: RoleID, to userId: UserID, on guildId: GuildID, reason: String?) -> Promise<Bool, any Error> {
        withClient(of: roleId) { $0.addGuildMemberRole(roleId, to: userId, on: guildId, reason: reason) } ?? Promise(.success(false))
    }

    public func removeGuildMemberRole(_ roleId: RoleID, from userId: UserID, on guildId: GuildID, reason: String?) -> Promise<Bool, any Error> {
        withClient(of: roleId) { $0.removeGuildMemberRole(roleId, from: userId, on: guildId, reason: reason) } ?? Promise(.success(false))
    }

    public func createDM(with userId: UserID) -> Promise<ChannelID?, any Error> {
        withClient(of: userId) { $0.createDM(with: userId) } ?? Promise(.success(nil))
    }

    public func sendMessage(_ message: Message, to channelId: ChannelID) -> Promise<Message?, any Error> {
        withClient(of: channelId) {
            log.info("Sending '\(message.content.truncated(to: 10, appending: "..."))' to \($0.name) channel \(channelId)")
            return $0.sendMessage(message, to: channelId)
        } ?? Promise(.success(nil))
    }

    public func editMessage(_ id: MessageID, on channelId: ChannelID, content: String) -> Promise<Message?, any Error> {
        withClient(of: channelId) { $0.editMessage(id, on: channelId, content: content) } ?? Promise(.success(nil))
    }

    public func deleteMessage(_ id: MessageID, on channelId: ChannelID) -> Promise<Bool, any Error> {
        withClient(of: channelId) { $0.deleteMessage(id, on: channelId) } ?? Promise(.success(false))
    }

    public func bulkDeleteMessages(_ ids: [MessageID], on channelId: ChannelID) -> Promise<Bool, any Error> {
        withClient(of: channelId) { $0.bulkDeleteMessages(ids, on: channelId) } ?? Promise(.success(false))
    }

    public func getMessages(for channelId: ChannelID, limit: Int, selection: MessageSelection?) -> Promise<[Message], any Error> {
        withClient(of: channelId) { $0.getMessages(for: channelId, limit: limit, selection: selection) } ?? Promise(.success([]))
    }

    public func modifyChannel(_ channelId: ChannelID, with modification: ChannelModification) -> Promise<Channel?, any Error> {
        withClient(of: channelId) { $0.modifyChannel(channelId, with: modification) } ?? Promise(.success(nil))
    }

    public func isGuildTextChannel(_ channelId: ChannelID) -> Promise<Bool, any Error> {
        withClient(of: channelId) { $0.isGuildTextChannel(channelId) } ?? Promise(.success(false))
    }

    public func isDMTextChannel(_ channelId: ChannelID) -> Promise<Bool, any Error> {
        withClient(of: channelId) { $0.isDMTextChannel(channelId) } ?? Promise(.success(false))
    }

    public func triggerTyping(on channelId: ChannelID) -> Promise<Bool, any Error> {
        withClient(of: channelId) { $0.triggerTyping(on: channelId) } ?? Promise(.success(false))
    }

    public func createReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) -> Promise<Message?, any Error> {
        withClient(of: channelId) { $0.createReaction(for: messageId, on: channelId, emoji: emoji) } ?? Promise(.success(nil))
    }

    public func deleteOwnReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) -> Promise<Bool, any Error> {
        withClient(of: channelId) { $0.deleteOwnReaction(for: messageId, on: channelId, emoji: emoji) } ?? Promise(.success(false))
    }

    public func deleteUserReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String, by userId: UserID) -> Promise<Bool, any Error> {
        withClient(of: channelId) { $0.deleteUserReaction(for: messageId, on: channelId, emoji: emoji, by: userId) } ?? Promise(.success(false))
    }

    public func createEmoji(on guildId: GuildID, name: String, image: String, roles: [RoleID]) -> Promise<Emoji?, any Error> {
        withClient(of: guildId) { $0.createEmoji(on: guildId, name: name, image: image, roles: roles) } ?? Promise(.success(nil))
    }

    public func deleteEmoji(from guildId: GuildID, emojiId: EmojiID) -> Promise<Bool, any Error> {
        withClient(of: guildId) { $0.deleteEmoji(from: guildId, emojiId: emojiId) } ?? Promise(.success(false))
    }

    public func getMIOCommands() -> Promise<[MIOCommand], any Error> {
        guard let client = mioCommandClient else { return Promise(.failure(MessageIOSinkError.noMIOCommandClient)) }
        return client.getMIOCommands()
    }

    public func createMIOCommand(name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, any Error> {
        guard let client = mioCommandClient else { return Promise(.failure(MessageIOSinkError.noMIOCommandClient)) }
        return client.createMIOCommand(name: name, description: description, options: options)
    }

    public func editMIOCommand(_ commandId: MIOCommandID, name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, any Error> {
        guard let client = mioCommandClient else { return Promise(.failure(MessageIOSinkError.noMIOCommandClient)) }
        return client.editMIOCommand(commandId, name: name, description: description, options: options)
    }

    public func deleteMIOCommand(_ commandId: MIOCommandID) -> Promise<Bool, any Error> {
        guard let client = mioCommandClient else { return Promise(.failure(MessageIOSinkError.noMIOCommandClient)) }
        return client.deleteMIOCommand(commandId)
    }

    public func getMIOCommands(on guildId: GuildID) -> Promise<[MIOCommand], any Error> {
        withClient(of: guildId) { $0.getMIOCommands(on: guildId) } ?? Promise(.failure(MessageIOSinkError.noMIOCommandClient))
    }

    public func createMIOCommand(on guildId: GuildID, name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, any Error> {
        withClient(of: guildId) { $0.createMIOCommand(on: guildId, name: name, description: description, options: options) } ?? Promise(.failure(MessageIOSinkError.noMIOCommandClient))
    }

    public func editMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID, name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, any Error> {
        withClient(of: guildId) { $0.editMIOCommand(commandId, on: guildId, name: name, description: description, options: options) } ?? Promise(.failure(MessageIOSinkError.noMIOCommandClient))
    }

    public func deleteMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID) -> Promise<Bool, any Error> {
        withClient(of: guildId) { $0.deleteMIOCommand(commandId, on: guildId) } ?? Promise(.failure(MessageIOSinkError.noMIOCommandClient))
    }

    public func createInteractionResponse(for interactionId: InteractionID, token: String, response: InteractionResponse) -> Promise<Bool, any Error> {
        guard let client = mioCommandClient else { return Promise(.failure(MessageIOSinkError.noMIOCommandClient)) }
        return client.createInteractionResponse(for: interactionId, token: token, response: response)
    }
}
