import Foundation
import Logging
import Utils

fileprivate let log = Logger(label: "D2MessageIO.MessageIOSink")

/// An entry-point for commands sent to the message backend.
public protocol MessageIOSink {
    var name: String { get }
    var me: User? { get }
    var guilds: [Guild]? { get }
    var messageFetchLimit: Int? { get }

    func guild(for guildId: GuildID) -> Guild?

    func channel(for channelId: ChannelID) -> Channel?

    func setPresence(_ presence: PresenceUpdate)

    func guildForChannel(_ channelId: ChannelID) -> Guild?

    func permissionsForUser(_ userId: UserID, in channelId: ChannelID, on guildId: GuildID) -> Permissions

    func avatarUrlForUser(_ userId: UserID, with avatarId: String, size: Int, preferredExtension: String?) -> URL?

    @discardableResult
    func addGuildMemberRole(_ roleId: RoleID, to userId: UserID, on guildId: GuildID, reason: String?) -> Promise<Bool, any Error>

    @discardableResult
    func removeGuildMemberRole(_ roleId: RoleID, from userId: UserID, on guildId: GuildID, reason: String?) -> Promise<Bool, any Error>

    @discardableResult
    func createDM(with userId: UserID) -> Promise<ChannelID?, any Error>

    @discardableResult
    func sendMessage(_ message: Message, to channelId: ChannelID) -> Promise<Message?, any Error>

    @discardableResult
    func editMessage(_ id: MessageID, on channelId: ChannelID, content: String) -> Promise<Message?, any Error>

    @discardableResult
    func deleteMessage(_ id: MessageID, on channelId: ChannelID) -> Promise<Bool, any Error>

    @discardableResult
    func bulkDeleteMessages(_ ids: [MessageID], on channelId: ChannelID) -> Promise<Bool, any Error>

    @discardableResult
    func getMessages(for channelId: ChannelID, limit: Int, selection: MessageSelection?) -> Promise<[Message], any Error>

    @discardableResult
    func modifyChannel(_ channelId: ChannelID, with modification: ChannelModification) -> Promise<Channel?, any Error>

    @discardableResult
    func isGuildTextChannel(_ channelId: ChannelID) -> Promise<Bool, any Error>

    @discardableResult
    func isDMTextChannel(_ channelId: ChannelID) -> Promise<Bool, any Error>

    @discardableResult
    func triggerTyping(on channelId: ChannelID) -> Promise<Bool, any Error>

    @discardableResult
    func createReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) -> Promise<Message?, any Error>

    @discardableResult
    func deleteOwnReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) -> Promise<Bool, any Error>

    @discardableResult
    func deleteUserReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String, by userId: UserID) -> Promise<Bool, any Error>

    @discardableResult
    func createEmoji(on guildId: GuildID, name: String, image: String, roles: [RoleID]) -> Promise<Emoji?, any Error>

    @discardableResult
    func deleteEmoji(from guildId: GuildID, emojiId: EmojiID) -> Promise<Bool, any Error>

    @discardableResult
    func getMIOCommands() -> Promise<[MIOCommand], any Error>

    @discardableResult
    func createMIOCommand(name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, any Error>

    @discardableResult
    func editMIOCommand(_ commandId: MIOCommandID, name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, any Error>

    @discardableResult
    func deleteMIOCommand(_ commandId: MIOCommandID) -> Promise<Bool, any Error>

    @discardableResult
    func getMIOCommands(on guildId: GuildID) -> Promise<[MIOCommand], any Error>

    @discardableResult
    func createMIOCommand(on guildId: GuildID, name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, any Error>

    @discardableResult
    func editMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID, name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, any Error>

    @discardableResult
    func deleteMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID) -> Promise<Bool, any Error>

    @discardableResult
    func createInteractionResponse(for interactionId: InteractionID, token: String, response: InteractionResponse) -> Promise<Bool, any Error>
}

public extension MessageIOSink {
    func sendMessage(_ content: String, to channelId: ChannelID) {
        sendMessage(Message(content: content), to: channelId)
    }

    func getMessages(for channelId: ChannelID, limit: Int) -> Promise<[Message], any Error> {
        getMessages(for: channelId, limit: limit, selection: nil)
    }

    func createEmoji(on guildId: GuildID, name: String, image: String) -> Promise<Emoji?, any Error> {
        createEmoji(on: guildId, name: name, image: image, roles: [])
    }

    func avatarUrlForUser(_ userId: UserID, with avatarId: String, size: Int) -> URL? {
        avatarUrlForUser(userId, with: avatarId, size: size, preferredExtension: nil)
    }

    func avatarUrlForUser(_ userId: UserID, with avatarId: String, preferredExtension: String? = nil) -> URL? {
        avatarUrlForUser(userId, with: avatarId, size: 512, preferredExtension: preferredExtension)
    }

    @discardableResult
    func createMIOCommand(name: String, description: String) -> Promise<MIOCommand?, any Error> {
        createMIOCommand(name: name, description: description, options: nil)
    }

    @discardableResult
    func editMIOCommand(_ commandId: MIOCommandID, name: String, description: String) -> Promise<MIOCommand?, any Error> {
        editMIOCommand(commandId, name: name, description: description, options: nil)
    }

    @discardableResult
    func createMIOCommand(on guildId: GuildID, name: String, description: String) -> Promise<MIOCommand?, any Error> {
        createMIOCommand(on: guildId, name: name, description: description, options: nil)
    }

    @discardableResult
    func editMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID, name: String, description: String) -> Promise<MIOCommand?, any Error> {
        editMIOCommand(commandId, on: guildId, name: name, description: description, options: nil)
    }

    @discardableResult
    func deleteMIOCommands() -> Promise<Void, any Error> {
        // Note how this only deletes *global* MIO commands
        getMIOCommands().then {
            all(promises: $0.map { cmd -> Promise<Bool, any Error> in
                log.info("Deleting MIO command with ID \(cmd.id)")
                return deleteMIOCommand(cmd.id)
            }).void()
        }
    }

    @discardableResult
    func deleteMIOCommands(on guildId: GuildID) -> Promise<Void, any Error> {
        getMIOCommands(on: guildId).then {
            all(promises: $0.map { cmd -> Promise<Bool, any Error> in
                log.info("Deleting MIO command with ID \(cmd.id) from guild \(guildId)")
                return deleteMIOCommand(cmd.id, on: guildId)
            }).void()
        }
    }
}
