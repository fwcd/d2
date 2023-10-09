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

    func addGuildMemberRole(_ roleId: RoleID, to userId: UserID, on guildId: GuildID, reason: String?) -> Promise<Bool, any Error> {
        // TODO
        Promise(.success(false))
    }

    func removeGuildMemberRole(_ roleId: RoleID, from userId: UserID, on guildId: GuildID, reason: String?) -> Promise<Bool, any Error> {
        // TODO
        Promise(.success(false))
    }

    func createDM(with userId: UserID) -> Promise<ChannelID?, any Error> {
        // TODO
        Promise(.success(nil))
    }

    func sendMessage(_ message: D2MessageIO.Message, to channelId: ChannelID) -> Promise<D2MessageIO.Message?, any Error> {
        // TODO
        Promise(.success(nil))
    }

    func editMessage(_ id: MessageID, on channelId: ChannelID, content: String) -> Promise<D2MessageIO.Message?, any Error> {
        // TODO
        Promise(.success(nil))
    }

    func deleteMessage(_ id: MessageID, on channelId: ChannelID) -> Promise<Bool, any Error> {
        // TODO
        Promise(.success(false))
    }

    func bulkDeleteMessages(_ ids: [MessageID], on channelId: ChannelID) -> Promise<Bool, any Error> {
        // TODO
        Promise(.success(false))
    }

    func getMessages(for channelId: ChannelID, limit: Int, selection: MessageSelection?) -> Promise<[D2MessageIO.Message], any Error> {
        // TODO
        Promise(.success([]))
    }

    func modifyChannel(_ channelId: ChannelID, with modification: ChannelModification) -> Promise<D2MessageIO.Channel?, any Error> {
        // TODO
        Promise(.success(nil))
    }

    func isGuildTextChannel(_ channelId: ChannelID) -> Promise<Bool, any Error> {
        // TODO
        Promise(.success(false))
    }

    func isDMTextChannel(_ channelId: ChannelID) -> Promise<Bool, any Error> {
        // TODO
        Promise(.success(false))
    }

    func triggerTyping(on channelId: ChannelID) -> Promise<Bool, any Error> {
        // TODO
        Promise(.success(false))
    }

    func createReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) -> Promise<D2MessageIO.Message?, any Error> {
        // TODO
        Promise(.success(nil))
    }

    func deleteOwnReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) -> Promise<Bool, any Error> {
        // TODO
        Promise(.success(false))
    }

    func deleteUserReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String, by userId: UserID) -> Promise<Bool, any Error> {
        // TODO
        Promise(.success(false))
    }

    func createEmoji(on guildId: GuildID, name: String, image: String, roles: [RoleID]) -> Promise<D2MessageIO.Emoji?, any Error> {
        // TODO
        Promise(.success(nil))
    }

    func deleteEmoji(from guildId: GuildID, emojiId: EmojiID) -> Promise<Bool, any Error> {
        // TODO
        Promise(.success(false))
    }

    func getMIOCommands() -> Promise<[MIOCommand], any Error> {
        // TODO
        Promise(.success([]))
    }

    func createMIOCommand(name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, any Error> {
        // TODO
        Promise(.success(nil))
    }

    func editMIOCommand(_ commandId: MIOCommandID, name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, any Error> {
        // TODO
        Promise(.success(nil))
    }

    func deleteMIOCommand(_ commandId: MIOCommandID) -> Promise<Bool, any Error> {
        // TODO
        Promise(.success(false))
    }

    func getMIOCommands(on guildId: GuildID) -> Promise<[MIOCommand], any Error> {
        // TODO
        Promise(.success([]))
    }

    func createMIOCommand(on guildId: GuildID, name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, any Error> {
        // TODO
        Promise(.success(nil))
    }

    func editMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID, name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, any Error> {
        // TODO
        Promise(.success(nil))
    }

    func deleteMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID) -> Promise<Bool, any Error> {
        // TODO
        Promise(.success(false))
    }

    func createInteractionResponse(for interactionId: InteractionID, token: String, response: InteractionResponse) -> Promise<Bool, any Error> {
        // TODO
        Promise(.success(false))
    }
}
