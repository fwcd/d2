import Foundation
import D2Utils

public protocol MessageClient {
    var name: String { get }
    var me: User? { get }
    var guilds: [Guild]? { get }
    var messageFetchLimit: Int? { get }

    func guild(for guildId: GuildID) -> Guild?

    func setPresence(_ presence: PresenceUpdate)

    func guildForChannel(_ channelId: ChannelID) -> Guild?

    func permissionsForUser(_ userId: UserID, in channelId: ChannelID, on guildId: GuildID) -> Permission

    @discardableResult
    func addGuildMemberRole(_ roleId: RoleID, to userId: UserID, on guildId: GuildID, reason: String?) -> Promise<Bool, Error>

    @discardableResult
    func removeGuildMemberRole(_ roleId: RoleID, from userId: UserID, on guildId: GuildID, reason: String?) -> Promise<Bool, Error>

    @discardableResult
    func createDM(with userId: UserID) -> Promise<ChannelID?, Error>

    @discardableResult
    func sendMessage(_ message: Message, to channelId: ChannelID) -> Promise<Message?, Error>

    @discardableResult
    func editMessage(_ id: MessageID, on channelId: ChannelID, content: String) -> Promise<Message?, Error>

    @discardableResult
    func deleteMessage(_ id: MessageID, on channelId: ChannelID) -> Promise<Bool, Error>

    @discardableResult
    func bulkDeleteMessages(_ ids: [MessageID], on channelId: ChannelID) -> Promise<Bool, Error>

    @discardableResult
    func getMessages(for channelId: ChannelID, limit: Int, selection: MessageSelection?) -> Promise<[Message], Error>

    @discardableResult
    func isGuildTextChannel(_ channelId: ChannelID) -> Promise<Bool, Error>

    @discardableResult
    func isDMTextChannel(_ channelId: ChannelID) -> Promise<Bool, Error>

    @discardableResult
    func triggerTyping(on channelId: ChannelID) -> Promise<Bool, Error>

    @discardableResult
    func createReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) -> Promise<Message?, Error>
}

public extension MessageClient {
    func sendMessage(_ content: String, to channelId: ChannelID) {
        sendMessage(Message(content: content), to: channelId)
    }

    func getMessages(for channelId: ChannelID, limit: Int) -> Promise<[Message], Error> {
        getMessages(for: channelId, limit: limit, selection: nil, then: then)
    }
}
