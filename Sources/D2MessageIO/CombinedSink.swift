import Foundation
import Utils
import Logging

fileprivate let log = Logger(label: "D2MessageIO.CombinedSink")

/// A Sink that combines multiple sinks and
/// dispatches requests dynamically based on the ID's sink name.
public class CombinedSink: Sink {
    private var sinks: [String: any Sink] = [:]

    private let mioCommandSinkName: String?
    private var mioCommandSink: (any Sink)? { mioCommandSinkName.flatMap { sinks[$0] } }

    public var me: User? { nil }
    public var name: String { "Combined" }
    public var guilds: [Guild]? { sinks.values.flatMap { $0.guilds ?? [] } }
    public var messageFetchLimit: Int? { sinks.values.compactMap { $0.messageFetchLimit }.min() }

    // TODO: Support more than one sink for global MIO commands
    public init(mioCommandSinkName: String? = nil) {
        self.mioCommandSinkName = mioCommandSinkName
    }

    @discardableResult
    public func register(sink: any Sink) -> any Sink {
        sinks[sink.name] = sink
        return OverlaySink(inner: self, name: sink.name, me: sink.me)
    }

    private func withSink<T>(of id: ID, _ action: (any Sink) throws -> T?) rethrows -> T? {
        if let sink = sinks[id.clientName] {
            return try action(sink)
        } else {
            log.warning("Could not find sink with name `\(id.clientName)`. This is a bug and might result in unhandled callbacks.")
            return nil
        }
    }

    private func withSink<T>(of id: ID, _ action: (any Sink) async throws -> T?) async rethrows -> T? {
        if let sink = sinks[id.clientName] {
            return try await action(sink)
        } else {
            log.warning("Could not find sink with name `\(id.clientName)`. This is a bug and might result in unhandled callbacks.")
            return nil
        }
    }

    public func guild(for guildId: GuildID) -> Guild? {
        withSink(of: guildId) { $0.guild(for: guildId) }
    }

    public func channel(for channelId: ChannelID) -> Channel? {
        withSink(of: channelId) { $0.channel(for: channelId) }
    }

    public func setPresence(_ presence: PresenceUpdate) async throws {
        for sink in sinks.values {
            try await sink.setPresence(presence)
        }
    }

    public func guildForChannel(_ channelId: ChannelID) -> Guild? {
        withSink(of: channelId) { $0.guildForChannel(channelId) }
    }

    public func permissionsForUser(_ userId: UserID, in channelId: ChannelID, on guildId: GuildID) -> Permissions {
        withSink(of: channelId) { $0.permissionsForUser(userId, in: channelId, on: guildId) } ?? []
    }

    public func avatarUrlForUser(_ userId: UserID, with avatarId: String, size: Int, preferredExtension: String?) -> URL? {
        withSink(of: userId) { $0.avatarUrlForUser(userId, with: avatarId, size: size, preferredExtension: preferredExtension) }
    }

    public func addGuildMemberRole(_ roleId: RoleID, to userId: UserID, on guildId: GuildID, reason: String?) async throws {
        try await withSink(of: roleId) { try await $0.addGuildMemberRole(roleId, to: userId, on: guildId, reason: reason) }
    }

    public func removeGuildMemberRole(_ roleId: RoleID, from userId: UserID, on guildId: GuildID, reason: String?) async throws {
        try await withSink(of: roleId) { try await $0.removeGuildMemberRole(roleId, from: userId, on: guildId, reason: reason) }
    }

    public func createDM(with userId: UserID) async throws -> ChannelID? {
        try await withSink(of: userId) { try await $0.createDM(with: userId) }
    }

    public func sendMessage(_ message: Message, to channelId: ChannelID) async throws -> Message? {
        try await withSink(of: channelId) {
            log.info("Sending '\(message.content.truncated(to: 10, appending: "..."))' to \($0.name) channel \(channelId)")
            return try await $0.sendMessage(message, to: channelId)
        }
    }

    public func editMessage(_ id: MessageID, on channelId: ChannelID, edit: Message.Edit) async throws -> Message? {
        try await withSink(of: channelId) { try await $0.editMessage(id, on: channelId, edit: edit) }
    }

    public func deleteMessage(_ id: MessageID, on channelId: ChannelID) async throws {
        try await withSink(of: channelId) { try await $0.deleteMessage(id, on: channelId) }
    }

    public func bulkDeleteMessages(_ ids: [MessageID], on channelId: ChannelID) async throws {
        try await withSink(of: channelId) { try await $0.bulkDeleteMessages(ids, on: channelId) }
    }

    public func getMessages(for channelId: ChannelID, limit: Int, selection: MessageSelection?) async throws -> [Message] {
        try await withSink(of: channelId) { try await $0.getMessages(for: channelId, limit: limit, selection: selection) } ?? []
    }

    public func modifyChannel(_ channelId: ChannelID, with modification: ChannelModification) async throws -> Channel? {
        try await withSink(of: channelId) { try await $0.modifyChannel(channelId, with: modification) }
    }

    public func isGuildTextChannel(_ channelId: ChannelID) async throws -> Bool {
        try await withSink(of: channelId) { try await $0.isGuildTextChannel(channelId) } ?? false
    }

    public func isDMTextChannel(_ channelId: ChannelID) async throws -> Bool {
        try await withSink(of: channelId) { try await $0.isDMTextChannel(channelId) } ?? false
    }

    public func triggerTyping(on channelId: ChannelID) async throws {
        try await withSink(of: channelId) { try await $0.triggerTyping(on: channelId) }
    }

    public func createReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) async throws -> Message? {
        try await withSink(of: channelId) { try await $0.createReaction(for: messageId, on: channelId, emoji: emoji) }
    }

    public func deleteOwnReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) async throws {
        try await withSink(of: channelId) { try await $0.deleteOwnReaction(for: messageId, on: channelId, emoji: emoji) }
    }

    public func deleteUserReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String, by userId: UserID) async throws {
        try await withSink(of: channelId) { try await $0.deleteUserReaction(for: messageId, on: channelId, emoji: emoji, by: userId) }
    }

    public func createEmoji(on guildId: GuildID, name: String, image: String, roles: [RoleID]) async throws -> Emoji? {
        try await withSink(of: guildId) { try await $0.createEmoji(on: guildId, name: name, image: image, roles: roles) }
    }

    public func deleteEmoji(from guildId: GuildID, emojiId: EmojiID) async throws {
        try await withSink(of: guildId) { try await $0.deleteEmoji(from: guildId, emojiId: emojiId) }
    }

    public func getMIOCommands() async throws -> [MIOCommand] {
        guard let sink = mioCommandSink else { throw SinkError.noMIOCommandSink }
        return try await sink.getMIOCommands()
    }

    public func createMIOCommand(name: String, description: String, options: [MIOCommand.Option]?) async throws -> MIOCommand? {
        guard let sink = mioCommandSink else { throw SinkError.noMIOCommandSink }
        return try await sink.createMIOCommand(name: name, description: description, options: options)
    }

    public func editMIOCommand(_ commandId: MIOCommandID, name: String, description: String, options: [MIOCommand.Option]?) async throws -> MIOCommand? {
        guard let sink = mioCommandSink else { throw SinkError.noMIOCommandSink }
        return try await sink.editMIOCommand(commandId, name: name, description: description, options: options)
    }

    public func deleteMIOCommand(_ commandId: MIOCommandID) async throws {
        guard let sink = mioCommandSink else { throw SinkError.noMIOCommandSink }
        return try await sink.deleteMIOCommand(commandId)
    }

    public func getMIOCommands(on guildId: GuildID) async throws -> [MIOCommand] {
        guard let commands = try await withSink(of: guildId, { try await $0.getMIOCommands(on: guildId) }) else {
            throw SinkError.noMIOCommandSink
        }
        return commands
    }

    public func createMIOCommand(on guildId: GuildID, name: String, description: String, options: [MIOCommand.Option]?) async throws -> MIOCommand? {
        guard let command = try await withSink(of: guildId, { try await $0.createMIOCommand(on: guildId, name: name, description: description, options: options) }) else {
            throw SinkError.noMIOCommandSink
        }
        return command
    }

    public func editMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID, name: String, description: String, options: [MIOCommand.Option]?) async throws -> MIOCommand? {
        guard let command = try await withSink(of: guildId, { try await $0.editMIOCommand(commandId, on: guildId, name: name, description: description, options: options) }) else {
            throw SinkError.noMIOCommandSink
        }
        return command
    }

    public func deleteMIOCommand(_ commandId: MIOCommandID, on guildId: GuildID) async throws {
        guard try await withSink(of: guildId, { try await $0.deleteMIOCommand(commandId, on: guildId) }) != nil else {
            throw SinkError.noMIOCommandSink
        }
    }

    public func createInteractionResponse(for interactionId: InteractionID, token: String, response: InteractionResponse) async throws {
        guard let sink = mioCommandSink else { throw SinkError.noMIOCommandSink }
        return try await sink.createInteractionResponse(for: interactionId, token: token, response: response)
    }
}
