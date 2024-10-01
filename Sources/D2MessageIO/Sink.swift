import Foundation
import Logging
import Utils

fileprivate let log = Logger(label: "D2MessageIO.Sink")

/// An entry-point for commands sent to the message backend.
public protocol Sink {
    var name: String { get }
    var me: User? { get }
    var guilds: [Guild]? { get }
    var messageFetchLimit: Int? { get }

    func guild(for guildId: GuildID) -> Guild?

    func channel(for channelId: ChannelID) -> Channel?

    func setPresence(_ presence: PresenceUpdate) async throws

    func guildForChannel(_ channelId: ChannelID) -> Guild?

    func permissionsForUser(_ userId: UserID, in channelId: ChannelID, on guildId: GuildID) -> Permissions

    func avatarUrlForUser(_ userId: UserID, with avatarId: String, size: Int, preferredExtension: String?) -> URL?

    func addGuildMemberRole(_ roleId: RoleID, to userId: UserID, on guildId: GuildID, reason: String?) async throws

    func removeGuildMemberRole(_ roleId: RoleID, from userId: UserID, on guildId: GuildID, reason: String?) async throws

    @discardableResult
    func createDM(with userId: UserID) async throws -> ChannelID?

    @discardableResult
    func sendMessage(_ message: Message, to channelId: ChannelID) async throws -> Message?

    @discardableResult
    func editMessage(_ id: MessageID, on channelId: ChannelID, edit: Message.Edit) async throws -> Message?

    func deleteMessage(_ id: MessageID, on channelId: ChannelID) async throws

    func bulkDeleteMessages(_ ids: [MessageID], on channelId: ChannelID) async throws

    @discardableResult
    func getMessages(for channelId: ChannelID, limit: Int, selection: MessageSelection?) async throws -> [Message]

    @discardableResult
    func modifyChannel(_ channelId: ChannelID, with modification: ChannelModification) async throws -> Channel?

    func isGuildTextChannel(_ channelId: ChannelID) async throws -> Bool

    func isDMTextChannel(_ channelId: ChannelID) async throws -> Bool

    func triggerTyping(on channelId: ChannelID) async throws

    @discardableResult
    func createReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) async throws -> Message?

    func deleteOwnReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) async throws

    func deleteUserReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String, by userId: UserID) async throws

    @discardableResult
    func createEmoji(on guildId: GuildID, name: String, image: String, roles: [RoleID]) async throws -> Emoji?

    func deleteEmoji(from guildId: GuildID, emojiId: EmojiID) async throws

    @discardableResult
    func getMIOCommands() async throws -> [MIOCommand]

    @discardableResult
    func createMIOCommand(name: String, description: String, options: [MIOCommand.Option]?) async throws -> MIOCommand?

    @discardableResult
    func editMIOCommand(_ commandId: MIOCommandID, name: String, description: String, options: [MIOCommand.Option]?) async throws -> MIOCommand?

    func deleteMIOCommand(_ commandId: MIOCommandID) async throws

    @discardableResult
    func getMIOCommands(on guildId: GuildID) async throws -> [MIOCommand]

    @discardableResult
    func createMIOCommand(on guildId: GuildID, name: String, description: String, options: [MIOCommand.Option]?) async throws -> MIOCommand?

    @discardableResult
    func editMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID, name: String, description: String, options: [MIOCommand.Option]?) async throws -> MIOCommand?

    func deleteMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID) async throws

    func createInteractionResponse(for interactionId: InteractionID, token: String, response: InteractionResponse) async throws
}

public extension Sink {
    func sendMessage(_ content: String, to channelId: ChannelID) async throws {
        try await sendMessage(Message(content: content), to: channelId)
    }

    @discardableResult
    func editMessage(_ id: MessageID, on channelId: ChannelID, content: String) async throws -> Message? {
        try await editMessage(id, on: channelId, edit: Message.Edit(content: content))
    }

    func getMessages(for channelId: ChannelID, limit: Int) async throws -> [Message] {
        try await getMessages(for: channelId, limit: limit, selection: nil)
    }

    func createEmoji(on guildId: GuildID, name: String, image: String) async throws -> Emoji? {
        try await createEmoji(on: guildId, name: name, image: image, roles: [])
    }

    func avatarUrlForUser(_ userId: UserID, with avatarId: String, size: Int) -> URL? {
        avatarUrlForUser(userId, with: avatarId, size: size, preferredExtension: nil)
    }

    func avatarUrlForUser(_ userId: UserID, with avatarId: String, preferredExtension: String? = nil) -> URL? {
        avatarUrlForUser(userId, with: avatarId, size: 512, preferredExtension: preferredExtension)
    }

    @discardableResult
    func createMIOCommand(name: String, description: String) async throws -> MIOCommand? {
        try await createMIOCommand(name: name, description: description, options: nil)
    }

    @discardableResult
    func editMIOCommand(_ commandId: MIOCommandID, name: String, description: String) async throws -> MIOCommand? {
        try await editMIOCommand(commandId, name: name, description: description, options: nil)
    }

    @discardableResult
    func createMIOCommand(on guildId: GuildID, name: String, description: String) async throws -> MIOCommand? {
        try await createMIOCommand(on: guildId, name: name, description: description, options: nil)
    }

    @discardableResult
    func editMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID, name: String, description: String) async throws -> MIOCommand? {
        try await editMIOCommand(commandId, on: guildId, name: name, description: description, options: nil)
    }

    func deleteMIOCommands() async throws {
        // Note how this only deletes *global* MIO commands
        for command in try await getMIOCommands() {
            log.info("Deleting MIO command with ID \(command.id)")
            try await deleteMIOCommand(command.id)
        }
    }

    func deleteMIOCommands(on guildId: GuildID) async throws {
        for command in try await getMIOCommands(on: guildId) {
            log.info("Deleting MIO command with ID \(command.id) from guild \(guildId)")
            try await deleteMIOCommand(command.id, on: guildId)
        }
    }
}
