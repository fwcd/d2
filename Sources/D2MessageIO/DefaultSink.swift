import Foundation
import Utils

/// A message client that may implement its methods only partially.
///
/// This is a separate protocol to ensure that message clients like
/// `OverlaySink` or `CombinedSink` implement the
/// full set of methods.
public protocol DefaultSink: Sink {}

public extension DefaultSink {
    var me: D2MessageIO.User? { nil }
    var messageFetchLimit: Int? { nil }
    var guilds: [Guild]? { nil }

    func guild(for guildId: GuildID) -> Guild? {
        // TODO
        nil
    }

    func channel(for channelId: ChannelID) -> Channel? {
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

    func permissionsForUser(_ userId: UserID, in channelId: ChannelID, on guildId: GuildID) -> Permissions {
        // TODO
        []
    }

    func avatarUrlForUser(_ userId: UserID, with avatarId: String, size: Int, preferredExtension: String?) -> URL? {
        // TODO
        nil
    }

    func addGuildMemberRole(_ roleId: RoleID, to userId: UserID, on guildId: GuildID, reason: String?) async throws -> Bool {
        // TODO
        false
    }

    func removeGuildMemberRole(_ roleId: RoleID, from userId: UserID, on guildId: GuildID, reason: String?) async throws -> Bool {
        // TODO
        false
    }

    func createDM(with userId: UserID) async throws -> ChannelID? {
        // TODO
        nil
    }

    func sendMessage(_ message: D2MessageIO.Message, to channelId: ChannelID) async throws -> D2MessageIO.Message? {
        // TODO
        nil
    }

    func editMessage(_ id: MessageID, on channelId: ChannelID, content: String) async throws -> D2MessageIO.Message? {
        // TODO
        nil
    }

    func deleteMessage(_ id: MessageID, on channelId: ChannelID) async throws -> Bool {
        // TODO
        false
    }

    func bulkDeleteMessages(_ ids: [MessageID], on channelId: ChannelID) async throws -> Bool {
        // TODO
        false
    }

    func getMessages(for channelId: ChannelID, limit: Int, selection: MessageSelection?) async throws -> [D2MessageIO.Message] {
        // TODO
        []
    }

    func modifyChannel(_ channelId: ChannelID, with modification: ChannelModification) async throws -> D2MessageIO.Channel? {
        // TODO
        nil
    }

    func isGuildTextChannel(_ channelId: ChannelID) async throws -> Bool {
        // TODO
        false
    }

    func isDMTextChannel(_ channelId: ChannelID) async throws -> Bool {
        // TODO
        false
    }

    func triggerTyping(on channelId: ChannelID) async throws -> Bool {
        // TODO
        false
    }

    func createReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) async throws -> D2MessageIO.Message? {
        // TODO
        nil
    }

    func deleteOwnReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) async throws -> Bool {
        // TODO
        false
    }

    func deleteUserReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String, by userId: UserID) async throws -> Bool {
        // TODO
        false
    }

    func createEmoji(on guildId: GuildID, name: String, image: String, roles: [RoleID]) async throws -> D2MessageIO.Emoji? {
        // TODO
        nil
    }

    func deleteEmoji(from guildId: GuildID, emojiId: EmojiID) async throws -> Bool {
        // TODO
        false
    }

    func getMIOCommands() async throws -> [MIOCommand] {
        // TODO
        []
    }

    func createMIOCommand(name: String, description: String, options: [MIOCommand.Option]?) async throws -> MIOCommand? {
        // TODO
        nil
    }

    func editMIOCommand(_ commandId: MIOCommandID, name: String, description: String, options: [MIOCommand.Option]?) async throws -> MIOCommand? {
        // TODO
        nil
    }

    func deleteMIOCommand(_ commandId: MIOCommandID) async throws -> Bool {
        // TODO
        false
    }

    func getMIOCommands(on guildId: GuildID) async throws -> [MIOCommand] {
        // TODO
        []
    }

    func createMIOCommand(on guildId: GuildID, name: String, description: String, options: [MIOCommand.Option]?) async throws -> MIOCommand? {
        // TODO
        nil
    }

    func editMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID, name: String, description: String, options: [MIOCommand.Option]?) async throws -> MIOCommand? {
        // TODO
        nil
    }

    func deleteMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID) async throws -> Bool {
        // TODO
        false
    }

    func createInteractionResponse(for interactionId: InteractionID, token: String, response: InteractionResponse) async throws -> Bool {
        // TODO
        false
    }
}
