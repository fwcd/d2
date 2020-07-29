import Logging

fileprivate let log = Logger(label: "D2MessageIO.CombinedMessageClient")

/**
 * A MessageClient that combines multiple clients and
 * dispatches requests dynamically based on the ID's client name.
 */
public class CombinedMessageClient: MessageClient {
    private var clients: [String: MessageClient] = [:]

    public var me: User? { nil }
    public var name: String { "Combined" }
    public var guilds: [Guild]? { clients.values.flatMap { $0.guilds ?? [] } }
    public var messageFetchLimit: Int? { clients.values.compactMap { $0.messageFetchLimit }.min() }

    public init() {}

    @discardableResult
    public func register(client: MessageClient) -> MessageClient {
        clients[client.name] = client
        return OverlayMessageClient(inner: self, name: client.name, me: client.me)
    }

    private func withClient<T>(of id: ID, _ action: (MessageClient) throws -> T?) rethrows -> T? {
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

    public func setPresence(_ presence: PresenceUpdate) {
        for client in clients.values {
            client.setPresence(presence)
        }
    }

    public func guildForChannel(_ channelId: ChannelID) -> Guild? {
        withClient(of: channelId) { $0.guildForChannel(channelId) }
    }

    public func permissionsForUser(_ userId: UserID, in channelId: ChannelID, on guildId: GuildID) -> Permission {
        withClient(of: channelId) { $0.permissionsForUser(userId, in: channelId, on: guildId) } ?? []
    }

    public func addGuildMemberRole(_ roleId: RoleID, to userId: UserID, on guildId: GuildID, reason: String?, then: ClientCallback<Bool>?) {
        withClient(of: roleId) { $0.addGuildMemberRole(roleId, to: userId, on: guildId, reason: reason, then: then) }
    }

    public func removeGuildMemberRole(_ roleId: RoleID, from userId: UserID, on guildId: GuildID, reason: String?, then: ClientCallback<Bool>?) {
        withClient(of: roleId) { $0.removeGuildMemberRole(roleId, from: userId, on: guildId, reason: reason, then: then) }
    }

    public func createDM(with userId: UserID, then: ClientCallback<ChannelID?>?) {
        withClient(of: userId) { $0.createDM(with: userId, then: then) }
    }

    public func sendMessage(_ message: Message, to channelId: ChannelID, then: ClientCallback<Message?>?) {
        withClient(of: channelId) {
            log.info("Sending message to channel \(channelId) with \($0.name)")
            $0.sendMessage(message, to: channelId, then: then)
        }
    }

    public func editMessage(_ id: MessageID, on channelId: ChannelID, content: String, then: ClientCallback<Message?>?) {
        withClient(of: channelId) { $0.editMessage(id, on: channelId, content: content, then: then) }
    }

    public func deleteMessage(_ id: MessageID, on channelId: ChannelID, then: ClientCallback<Bool>?) {
        withClient(of: channelId) { $0.deleteMessage(id, on: channelId, then: then) }
    }

    public func bulkDeleteMessages(_ ids: [MessageID], on channelId: ChannelID, then: ClientCallback<Bool>?) {
        withClient(of: channelId) { $0.bulkDeleteMessages(ids, on: channelId, then: then) }
    }

    public func getMessages(for channelId: ChannelID, limit: Int, selection: MessageSelection?, then: ClientCallback<[Message]>?) {
        withClient(of: channelId) { $0.getMessages(for: channelId, limit: limit, selection: selection, then: then) }
    }

    public func isGuildTextChannel(_ channelId: ChannelID, then: ClientCallback<Bool>?) {
        withClient(of: channelId) { $0.isGuildTextChannel(channelId, then: then) }
    }

    public func isDMTextChannel(_ channelId: ChannelID, then: ClientCallback<Bool>?) {
        withClient(of: channelId) { $0.isDMTextChannel(channelId, then: then) }
    }

    public func triggerTyping(on channelId: ChannelID, then: ClientCallback<Bool>?) {
        withClient(of: channelId) { $0.triggerTyping(on: channelId, then: then) }
    }

    public func createReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String, then: ClientCallback<Message?>?) {
        withClient(of: channelId) { $0.createReaction(for: messageId, on: channelId, emoji: emoji, then: then) }
    }
}
