import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Utils
import D2MessageIO
import Logging
import Discord

fileprivate let log = Logger(label: "D2DiscordIO.DiscordSink")

struct DiscordSink: DefaultSink {
    private let client: DiscordClient

    var name: String { discordClientName }
    var me: User? { client.user?.usingMessageIO }
    var guilds: [Guild]? { client.guilds.values.map { $0.usingMessageIO } }
    var messageFetchLimit: Int? { 80 }

    init(client: DiscordClient) {
        self.client = client
    }

    func guild(for guildId: D2MessageIO.GuildID) -> Guild? {
        client.guilds[guildId.usingDiscordAPI]?.usingMessageIO
    }

    func channel(for channelId: D2MessageIO.ChannelID) -> Channel? {
        client.findChannel(fromId: channelId.usingDiscordAPI)?.usingMessageIO
    }

    func setPresence(_ presence: PresenceUpdate) {
        client.setPresence(presence.usingDiscordAPI)
    }

    func guildForChannel(_ channelId: D2MessageIO.ChannelID) -> Guild? {
        client.guildForChannel(channelId.usingDiscordAPI)?.usingMessageIO
    }

    func permissionsForUser(_ userId: D2MessageIO.UserID, in channelId: D2MessageIO.ChannelID, on guildId: D2MessageIO.GuildID) -> Permissions {
        guard let guild = client.guildForChannel(channelId.usingDiscordAPI),
              let member = guild.members?[userId.usingDiscordAPI] else {
            log.warning("Could not check Discord permission of user \(userId) in channel \(channelId)!")
            return []
        }

        return guild.permissions(for: member, in: channelId.usingDiscordAPI)?.usingMessageIO ?? []
    }

    func avatarUrlForUser(_ userId: D2MessageIO.UserID, with avatarId: String, size: Int, preferredExtension: String?) -> URL? {
        var components = URLComponents()

        let inferredExtension = avatarId.starts(with: "a_") ? "gif" : "png"

        components.scheme = "https"
        components.host = "cdn.discordapp.com"
        components.path = "/avatars/\(userId.usingDiscordAPI)/\(avatarId).\(preferredExtension ?? inferredExtension)"
        components.queryItems = [URLQueryItem(name: "size", value: String(size))]

        return components.url
    }

    func addGuildMemberRole(_ roleId: D2MessageIO.RoleID, to userId: D2MessageIO.UserID, on guildId: D2MessageIO.GuildID, reason: String?) async throws {
        try await withCheckedThrowingContinuation { continuation in
            client.addGuildMemberRole(roleId.usingDiscordAPI, to: userId.usingDiscordAPI, on: guildId.usingDiscordAPI) { success, response in
                continuation.resume(with: Result { try check(success: success, response: response, "adding guild member role") })
            }
        }
    }

    func removeGuildMemberRole(_ roleId: D2MessageIO.RoleID, from userId: D2MessageIO.UserID, on guildId: D2MessageIO.GuildID, reason: String?) async throws {
        try await withCheckedThrowingContinuation { continuation in
            client.removeGuildMemberRole(roleId.usingDiscordAPI, from: userId.usingDiscordAPI, on: guildId.usingDiscordAPI) { success, response in
                continuation.resume(with: Result { try check(success: success, response: response, "removing guild member role") })
            }
        }
    }

    func createDM(with userId: D2MessageIO.UserID) async throws -> D2MessageIO.ChannelID? {
        try await withCheckedThrowingContinuation { continuation in
            client.createDM(with: userId.usingDiscordAPI) { channel, response in
                continuation.resume(with: Result { try check(value: channel?.id.usingMessageIO, response: response, "creating DM") })
            }
        }
    }

    func sendMessage(_ message: Message, to channelId: D2MessageIO.ChannelID) async throws -> Message? {
        try await withCheckedThrowingContinuation { continuation in
            client.sendMessage(message.usingDiscordAPI, to: channelId.usingDiscordAPI) { message, response in
                continuation.resume(with: Result { try check(value: message?.usingMessageIO(with: self), response: response, "sending message") })
            }
        }
    }

    func editMessage(_ id: D2MessageIO.MessageID, on channelId: D2MessageIO.ChannelID, edit: Message.Edit) async throws -> Message? {
        try await withCheckedThrowingContinuation { continuation in
            client.editMessage(id.usingDiscordAPI, on: channelId.usingDiscordAPI, edit: edit.usingDiscordAPI) { message, response in
                continuation.resume(with: Result { try check(value: message?.usingMessageIO(with: self), response: response, "editing message") })
            }
        }
    }

    func deleteMessage(_ id: D2MessageIO.MessageID, on channelId: D2MessageIO.ChannelID) async throws {
        try await withCheckedThrowingContinuation { continuation in
            client.deleteMessage(id.usingDiscordAPI, on: channelId.usingDiscordAPI) { success, response in
                continuation.resume(with: Result { try check(success: success, response: response, "deleting message") })
            }
        }
    }

    func bulkDeleteMessages(_ ids: [D2MessageIO.MessageID], on channelId: D2MessageIO.ChannelID) async throws {
        try await withCheckedThrowingContinuation { continuation in
            client.bulkDeleteMessages(ids.map { $0.usingDiscordAPI }, on: channelId.usingDiscordAPI) { success, response in
                continuation.resume(with: Result { try check(success: success, response: response, "bulk-deleting messages") })
            }
        }
    }

    func getMessages(for channelId: D2MessageIO.ChannelID, limit: Int, selection: MessageSelection?) async throws -> [Message] {
        try await withCheckedThrowingContinuation { continuation in
            client.getMessages(for: channelId.usingDiscordAPI, selection: selection?.usingDiscordAPI, limit: limit) { messages, response in
                continuation.resume(with: Result { try check(value: messages.map { $0.usingMessageIO(with: self) }, response: response, "getting messages") })
            }
        }
    }

    func modifyChannel(_ channelId: D2MessageIO.ChannelID, with modification: ChannelModification) async throws -> Channel? {
        try await withCheckedThrowingContinuation { continuation in
            client.modifyChannel(channelId.usingDiscordAPI, options: modification.usingDiscordAPI) { channel, response in
                continuation.resume(with: Result { try check(value: channel?.usingMessageIO, response: response, "modifying channel") })
            }
        }
    }

    func isGuildTextChannel(_ channelId: D2MessageIO.ChannelID) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            client.getChannel(channelId.usingDiscordAPI) { channel, response in
                continuation.resume(with: Result { try check(value: channel.map { $0.type == .text } ?? false, response: response, "checking whether is guild channel") })
            }
        }
    }

    func isDMTextChannel(_ channelId: D2MessageIO.ChannelID) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            client.getChannel(channelId.usingDiscordAPI) { channel, response in
                continuation.resume(with: Result { try check(value: channel.map(\.isDM) ?? false, response: response, "checking whether is DM channel") })
            }
        }
    }

    func triggerTyping(on channelId: D2MessageIO.ChannelID) async throws {
        try await withCheckedThrowingContinuation { continuation in
            client.triggerTyping(on: channelId.usingDiscordAPI) { success, response in
                continuation.resume(with: Result { try check(success: success, response: response, "triggering typing") })
            }
        }
    }

    func createReaction(for messageId: D2MessageIO.MessageID, on channelId: D2MessageIO.ChannelID, emoji: String) async throws -> Message? {
        await withCheckedContinuation { continuation in
            client.createReaction(for: messageId.usingDiscordAPI, on: channelId.usingDiscordAPI, emoji: emoji) { m, _ in
                continuation.resume(returning: m?.usingMessageIO(with: self))
            }
        }
    }

    func deleteOwnReaction(for messageId: D2MessageIO.MessageID, on channelId: D2MessageIO.ChannelID, emoji: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            client.deleteOwnReaction(for: messageId.usingDiscordAPI, on: channelId.usingDiscordAPI, emoji: emoji) { success, response in
                continuation.resume(with: Result { try check(success: success, response: response, "deleting own reaction") })
            }
        }
    }

    func deleteUserReaction(for messageId: D2MessageIO.MessageID, on channelId: D2MessageIO.ChannelID, emoji: String, by userId: D2MessageIO.UserID) async throws {
        try await withCheckedThrowingContinuation { continuation in
            client.deleteUserReaction(for: messageId.usingDiscordAPI, on: channelId.usingDiscordAPI, emoji: emoji, by: userId.usingDiscordAPI) { success, response in
                continuation.resume(with: Result { try check(success: success, response: response, "deleting user reaction") })
            }
        }
    }

    func createEmoji(on guildId: D2MessageIO.GuildID, name: String, image: String, roles: [D2MessageIO.RoleID]) async throws -> Emoji? {
        try await withCheckedThrowingContinuation { continuation in
            client.createGuildEmoji(on: guildId.usingDiscordAPI, name: name, image: image, roles: roles.usingDiscordAPI) { emoji, response in
                continuation.resume(with: Result { try check(value: emoji?.usingMessageIO, response: response, "creating emoji") })
            }
        }
    }

    func deleteEmoji(from guildId: D2MessageIO.GuildID, emojiId: D2MessageIO.EmojiID) async throws {
        try await withCheckedThrowingContinuation { continuation in
            client.deleteGuildEmoji(on: guildId.usingDiscordAPI, for: emojiId.usingDiscordAPI) { success, response in
                continuation.resume(with: Result { try check(success: success, response: response, "deleting emoji") })
            }
        }
    }

    func getMIOCommands() async throws -> [MIOCommand] {
        await withCheckedContinuation { continuation in
            client.getApplicationCommands { cs, _ in
                continuation.resume(returning: cs.usingMessageIO)
            }
        }
    }

    func createMIOCommand(name: String, description: String, options: [MIOCommand.Option]?) async throws -> MIOCommand? {
        try await withCheckedThrowingContinuation { continuation in
            client.createApplicationCommand(name: name, description: description, options: options?.usingDiscordAPI) { command, response in
                continuation.resume(with: Result { try check(value: command?.usingMessageIO, response: response, "creating MIO command") })
            }
        }
    }

    func editMIOCommand(_ commandId: MIOCommandID, name: String, description: String, options: [MIOCommand.Option]?) async throws -> MIOCommand? {
        try await withCheckedThrowingContinuation { continuation in
            client.editApplicationCommand(commandId.usingDiscordAPI, name: name, description: description, options: options?.usingDiscordAPI) { command, response in
                continuation.resume(with: Result { try check(value: command?.usingMessageIO, response: response, "editing MIO command") })
            }
        }
    }

    func deleteMIOCommand(_ commandId: MIOCommandID) async throws {
        try await withCheckedThrowingContinuation { continuation in
            client.deleteApplicationCommand(commandId.usingDiscordAPI) { (data, response) in
                // TODO: Return data in error
                continuation.resume(with: Result { try check(response: response, "deleting MIO command") })
            }
        }
    }

    func getMIOCommands(on guildId: D2MessageIO.GuildID) async throws -> [MIOCommand] {
        await withCheckedContinuation { continuation in
            client.getApplicationCommands(on: guildId.usingDiscordAPI) { cs, _ in
                continuation.resume(returning: cs.usingMessageIO)
            }
        }
    }

    func createMIOCommand(on guildId: D2MessageIO.GuildID, name: String, description: String, options: [MIOCommand.Option]?) async throws -> MIOCommand? {
        try await withCheckedThrowingContinuation { continuation in
            client.createApplicationCommand(on: guildId.usingDiscordAPI, name: name, description: description, options: options?.usingDiscordAPI) { command, response in
                continuation.resume(with: Result { try check(value: command?.usingMessageIO, response: response, "creating MIO command") })
            }
        }
    }

    func editMIOCommand(_ commandId: MIOCommandID, on guildId: D2MessageIO.GuildID, name: String, description: String, options: [MIOCommand.Option]?) async throws -> MIOCommand? {
        try await withCheckedThrowingContinuation { continuation in
            client.editApplicationCommand(commandId.usingDiscordAPI, on: guildId.usingDiscordAPI, name: name, description: description, options: options?.usingDiscordAPI) { command, response in
                continuation.resume(with: Result { try check(value: command?.usingMessageIO, response: response, "editing MIO command") })
            }
        }
    }

    func deleteMIOCommand(_ commandId: MIOCommandID, on guildId: D2MessageIO.GuildID) async throws {
        try await withCheckedThrowingContinuation { continuation in
            client.deleteApplicationCommand(commandId.usingDiscordAPI, on: guildId.usingDiscordAPI) { (data, response) in
                // TODO: Return data in error
                continuation.resume(with: Result { try check(response: response, "deleting MIO command") })
            }
        }
    }

    func createInteractionResponse(for interactionId: D2MessageIO.InteractionID, token: String, response: InteractionResponse) async throws {
        try await withCheckedThrowingContinuation { continuation in
            client.createInteractionResponse(for: interactionId.usingDiscordAPI, token: token, response: response.usingDiscordAPI) { (data, response) in
                // TODO: Return data in error
                continuation.resume(with: Result { try check(response: response, "creating interaction response") })
            }
        }
    }

    private func check(response: HTTPURLResponse?, _ message: String) throws {
        guard let response else { throw DiscordSinkError.noResponse(message) }
        guard response.statusCode >= 200 && response.statusCode < 300 else { throw DiscordSinkError.httpError(message, status: response.statusCode) }
    }

    private func check<T>(value: T?, response: HTTPURLResponse?, _ message: String) throws -> T {
        try check(response: response, message)
        guard let value else { throw DiscordSinkError.unsuccessful(message, response: response) }
        return value
    }

    private func check(success: Bool, response: HTTPURLResponse?, _ message: String) throws {
        guard success else { throw DiscordSinkError.unsuccessful(message, response: response) }
        try check(response: response, message)
    }
}
