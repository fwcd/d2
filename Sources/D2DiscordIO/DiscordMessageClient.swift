import D2Utils
import D2MessageIO
import Logging
import SwiftDiscord

fileprivate let log = Logger(label: "D2DiscordIO.DiscordMessageClient")

struct DiscordMessageClient: MessageClient {
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

    func setPresence(_ presence: PresenceUpdate) {
        client.setPresence(presence.usingDiscordAPI)
    }

    func guildForChannel(_ channelId: D2MessageIO.ChannelID) -> Guild? {
        client.guildForChannel(channelId.usingDiscordAPI)?.usingMessageIO
    }

    func permissionsForUser(_ userId: D2MessageIO.UserID, in channelId: D2MessageIO.ChannelID, on guildId: D2MessageIO.GuildID) -> Permission {
        // Partly based on MIT-licensed code from https://github.com/nuclearace/SwiftDiscord/blob/9e2be352a580b1c9cf92149be335f61192b85bdb/Sources/SwiftDiscord/Guild/DiscordGuildChannel.swift#L91-L136
        // Copyright (c) 2016 Erik Little

        guard let guild = client.guildForChannel(channelId.usingDiscordAPI),
                let channel = guild.channels[channelId.usingDiscordAPI],
                let everybodyRole = guild.roles[guildId.usingDiscordAPI] else {
            log.warning("Could not check Discord permission of user \(userId) in channel \(channelId)!")
            return []
        }
        var permissions = everybodyRole.permissions

        if let everybodyOverwrite = channel.permissionOverwrites[guildId.usingDiscordAPI] {
            permissions.subtract(everybodyOverwrite.deny)
            permissions.formUnion(everybodyOverwrite.allow)
        }

        if !permissions.contains(.sendMessages) {
            // If they can't send messages, they automatically lose some permissions
            permissions.subtract([.sendTTSMessages, .mentionEveryone, .attachFiles, .embedLinks])
        }

        if !permissions.contains(.readMessages) {
            // If they can't read, they lose all channel based permissions
            permissions.subtract(.allChannel)
        }

        if channel is DiscordGuildTextChannel {
            // Text channels don't have voice permissions.
            permissions.subtract(.voice)
        }

        return permissions.usingMessageIO
    }

    func addGuildMemberRole(_ roleId: D2MessageIO.RoleID, to userId: D2MessageIO.UserID, on guildId: D2MessageIO.GuildID, reason: String?) -> Promise<Bool, Error> {
        Promise { then in
            client.addGuildMemberRole(roleId.usingDiscordAPI, to: userId.usingDiscordAPI, on: guildId.usingDiscordAPI) {
                then(Result.from($0, errorIfNil: DiscordMessageClientError.invalidResponse($1)))
            }
        }
    }

    func removeGuildMemberRole(_ roleId: D2MessageIO.RoleID, from userId: D2MessageIO.UserID, on guildId: D2MessageIO.GuildID, reason: String?) -> Promise<Bool, Error> {
        Promise { then in
            client.removeGuildMemberRole(roleId.usingDiscordAPI, from: userId.usingDiscordAPI, on: guildId.usingDiscordAPI) {
                then(Result.from($0, errorIfNil: DiscordMessageClientError.invalidResponse($1)))
            }
        }
    }

    func createDM(with userId: D2MessageIO.UserID) -> Promise<D2MessageIO.ChannelID?, Error> {
        Promise { then in
            client.createDM(with: userId.usingDiscordAPI) {
                then(Result.from($0?.id.usingMessageIO, errorIfNil: DiscordMessageClientError.invalidResponse($1)))
            }
        }
    }

    func sendMessage(_ message: Message, to channelId: D2MessageIO.ChannelID) -> Promise<Message?, Error> {
        Promise { then in
            client.sendMessage(message.usingDiscordAPI, to: channelId.usingDiscordAPI) {
                then(Result.from($0?.usingMessageIO, errorIfNil: DiscordMessageClientError.invalidResponse($1)))
            }
        }
    }

    func editMessage(_ id: D2MessageIO.MessageID, on channelId: D2MessageIO.ChannelID, content: String) -> Promise<Message?, Error> {
        Promise { then in
            client.editMessage(id.usingDiscordAPI, on: channelId.usingDiscordAPI, content: content) {
                then(Result.from($0?.usingMessageIO, errorIfNil: DiscordMessageClientError.invalidResponse($1)))
            }
        }
    }

    func deleteMessage(_ id: D2MessageIO.MessageID, on channelId: D2MessageIO.ChannelID) -> Promise<Bool, Error> {
        Promise { then in
            client.deleteMessage(id.usingDiscordAPI, on: channelId.usingDiscordAPI) {
                then(Result.from($0, errorIfNil: DiscordMessageClientError.invalidResponse($1)))
            }
        }
    }

    func bulkDeleteMessages(_ ids: [D2MessageIO.MessageID], on channelId: D2MessageIO.ChannelID) -> Promise<Bool, Error> {
        Promise { then in
            client.bulkDeleteMessages(ids.map { $0.usingDiscordAPI }, on: channelId.usingDiscordAPI) {
                then(Result.from($0, errorIfNil: DiscordMessageClientError.invalidResponse($1)))
            }
        }
    }

    func getMessages(for channelId: D2MessageIO.ChannelID, limit: Int, selection: MessageSelection?) -> Promise<[Message], Error> {
        Promise { then in
            client.getMessages(for: channelId.usingDiscordAPI, selection: selection?.usingDiscordAPI, limit: limit) {
                then(Result.from($0.map(\.usingMessageIO), errorIfNil: DiscordMessageClientError.invalidResponse($1)))
            }
        }
    }

    func isGuildTextChannel(_ channelId: D2MessageIO.ChannelID) -> Promise<Bool, Error> {
        Promise { then in
            client.getChannel(channelId.usingDiscordAPI) {
                then(Result.from($0.map { $0 is DiscordGuildTextChannel } ?? false, errorIfNil: DiscordMessageClientError.invalidResponse($1)))
            }
        }
    }

    func isDMTextChannel(_ channelId: D2MessageIO.ChannelID) -> Promise<Bool, Error> {
        Promise { then in
            client.getChannel(channelId.usingDiscordAPI) {
                then(Result.from($0.map { $0 is DiscordDMChannel || $0 is DiscordGroupDMChannel } ?? false, errorIfNil: DiscordMessageClientError.invalidResponse($1)))
            }
        }
    }

    func triggerTyping(on channelId: D2MessageIO.ChannelID) -> Promise<Bool, Error> {
        Promise { then in
            client.triggerTyping(on: channelId.usingDiscordAPI) {
                then(Result.from($0, errorIfNil: DiscordMessageClientError.invalidResponse($1)))
            }
        }
    }

    func createReaction(for messageId: D2MessageIO.MessageID, on channelId: D2MessageIO.ChannelID, emoji: String) -> Promise<Message?, Error> {
        Promise { then in
            client.createReaction(for: messageId.usingDiscordAPI, on: channelId.usingDiscordAPI, emoji: emoji) {
                then(Result.from($0?.usingMessageIO, errorIfNil: DiscordMessageClientError.invalidResponse($1)))
            }
        }
    }

    public func createEmoji(on guildId: D2MessageIO.GuildID, name: String, image: String, roles: [D2MessageIO.RoleID]) -> Promise<Emoji?, Error> {
        Promise { then in
            client.createGuildEmoji(on: guildId.usingDiscordAPI, name: name, image: image, roles: roles.usingDiscordAPI) {
                then(Result.from($0?.usingMessageIO, errorIfNil: DiscordMessageClientError.invalidResponse($1)))
            }
        }
    }

    public func deleteEmoji(from guildId: D2MessageIO.GuildID, emojiId: D2MessageIO.EmojiID) -> Promise<Bool, Error> {
        Promise { then in
            client.deleteGuildEmoji(on: guildId.usingDiscordAPI, for: emojiId.usingDiscordAPI) {
                then(Result.from($0, errorIfNil: DiscordMessageClientError.invalidResponse($1)))
            }
        }
    }
}
