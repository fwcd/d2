import Foundation
import Utils
import D2MessageIO
@testable import D2Commands

/// An implementation of CommandOutput and MessageClient
/// that writes all messages into an array.
public class TestOutput {
    private var internalMessages = [Message]() {
        didSet {
            changed = true
        }
    }
    public var guilds: [Guild]? = []

    /// Whether the output changed since the last read.
    public private(set) var changed = false
    public var messages: [Message] {
        changed = false
        return internalMessages
    }
    public var contents: [String] { return messages.map { $0.content } }
    public var last: Message? { return messages.last }
    public var lastContent: String? { return last?.content }
    public var lastEmbedDescription: String? { return last?.embeds.first?.description }

    private let messageWriter = MessageWriter()

    public init() {}

    public func nthLast(_ n: Int = 1) -> Message? {
        messages[safely: messages.count - n]
    }

    public func nthLastContent(_ n: Int = 1) -> String? {
        nthLast(n)?.content
    }

    private func append(message: Message) {
        internalMessages.append(message)
    }
}

extension TestOutput: CommandOutput {
    public func append(_ value: RichValue, to channel: OutputChannel) {
        messageWriter.write(value: value).listen { [self] in
            internalMessages.append(try! $0.get())
        }
    }

    public func update(context: CommandContext) {
        // Ignore
    }
}

extension TestOutput: MessageClient {
    public var name: String { "Test" }
    public var me: D2MessageIO.User? { nil }
    public var messageFetchLimit: Int? { nil }

    public func guild(for guildId: GuildID) -> Guild? {
        guilds?.first { $0.id == guildId }
    }

    public func setPresence(_ presence: PresenceUpdate) {
        // TODO
    }

    public func guildForChannel(_ channelId: ChannelID) -> Guild? {
        guilds?.first { $0.channels.keys.contains(channelId) }
    }

    public func permissionsForUser(_ userId: UserID, in channelId: ChannelID, on guildId: GuildID) -> Permission {
        // TODO
        []
    }

    public func avatarUrlForUser(_ userId: UserID, with avatarId: String, size: Int, preferredExtension: String?) -> URL? {
        // TODO
        nil
    }

    public func addGuildMemberRole(_ roleId: RoleID, to userId: UserID, on guildId: GuildID, reason: String?) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    public func removeGuildMemberRole(_ roleId: RoleID, from userId: UserID, on guildId: GuildID, reason: String?) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    public func createDM(with userId: UserID) -> Promise<ChannelID?, Error> {
        // TODO
        Promise(.success(nil))
    }

    public func sendMessage(_ message: D2MessageIO.Message, to channelId: ChannelID) -> Promise<D2MessageIO.Message?, Error> {
        append(message: message)
        return Promise(.success(message))
    }

    public func editMessage(_ id: MessageID, on channelId: ChannelID, content: String) -> Promise<D2MessageIO.Message?, Error> {
        // TODO
        Promise(.success(nil))
    }

    public func deleteMessage(_ id: MessageID, on channelId: ChannelID) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    public func bulkDeleteMessages(_ ids: [MessageID], on channelId: ChannelID) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    public func getMessages(for channelId: ChannelID, limit: Int, selection: MessageSelection?) -> Promise<[D2MessageIO.Message], Error> {
        // TODO
        Promise(.success([]))
    }

    public func isGuildTextChannel(_ channelId: ChannelID) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    public func isDMTextChannel(_ channelId: ChannelID) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    public func triggerTyping(on channelId: ChannelID) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    public func createReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) -> Promise<D2MessageIO.Message?, Error> {
        // TODO
        Promise(.success(nil))
    }

    public func deleteOwnReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    public func deleteUserReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String, by userId: UserID) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    public func createEmoji(on guildId: GuildID, name: String, image: String, roles: [RoleID]) -> Promise<D2MessageIO.Emoji?, Error> {
        // TODO
        Promise(.success(nil))
    }

    public func deleteEmoji(from guildId: GuildID, emojiId: EmojiID) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    public func getMIOCommands() -> Promise<[MIOCommand], Error> {
        // TODO
        Promise(.success([]))
    }

    public func createMIOCommand(name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, Error> {
        // TODO
        Promise(.success(nil))
    }

    public func editMIOCommand(_ commandId: MIOCommandID, name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, Error> {
        // TODO
        Promise(.success(nil))
    }

    public func deleteMIOCommand(_ commandId: MIOCommandID) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    public func getMIOCommands(on guildId: GuildID) -> Promise<[MIOCommand], Error> {
        // TODO
        Promise(.success([]))
    }

    public func createMIOCommand(on guildId: GuildID, name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, Error> {
        // TODO
        Promise(.success(nil))
    }

    public func editMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID, name: String, description: String, options: [MIOCommand.Option]?) -> Promise<MIOCommand?, Error> {
        // TODO
        Promise(.success(nil))
    }

    public func deleteMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    public func createInteractionResponse(for interactionId: InteractionID, token: String, response: InteractionResponse) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }
}
