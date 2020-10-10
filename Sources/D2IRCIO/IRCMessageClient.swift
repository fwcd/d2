import Foundation
import D2MessageIO
import Utils
import Emoji
import IRC
import Logging

fileprivate let log = Logger(label: "D2IRCIO.IRCMessageClient")
fileprivate let mentionPattern = try! Regex(from: "<@.+?>")

struct IRCMessageClient: MessageClient {
    private let ircClient: IRCClient

    var me: D2MessageIO.User? { nil } // TODO
    let name: String
    var guilds: [Guild]? { nil }
    var messageFetchLimit: Int? { nil }

    init(ircClient: IRCClient, name: String) {
        self.ircClient = ircClient
        self.name = name
    }

    func guild(for guildId: GuildID) -> Guild? {
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

    func permissionsForUser(_ userId: UserID, in channelId: ChannelID, on guildId: GuildID) -> Permission {
        // TODO
        []
    }

    func avatarUrlForUser(_ userId: UserID, with avatarId: String, size: Int) -> URL? {
        // TODO
        nil
    }

    func addGuildMemberRole(_ roleId: RoleID, to userId: UserID, on guildId: GuildID, reason: String?) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    func removeGuildMemberRole(_ roleId: RoleID, from userId: UserID, on guildId: GuildID, reason: String?) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    func createDM(with userId: UserID) -> Promise<ChannelID?, Error> {
        // TODO
        Promise(.success(nil))
    }

    private func flatten(embed: Embed) -> String {
        let lines: [String?] = [
            embed.title.flatMap { title in embed.url.map { "[\(title)](\($0.absoluteString))" } ?? title },
            embed.description
        ] + embed.fields.flatMap { ["**\($0.name)**", $0.value] } + [
            embed.footer?.text
        ]
        return lines
            .compactMap { $0 }
            .joined(separator: ", ")
    }

    func sendMessage(_ message: D2MessageIO.Message, to channelId: ChannelID) -> Promise<D2MessageIO.Message?, Error> {
        log.debug("Sending message '\(message.content)'")

        var text = [message.content, message.embed.map(flatten(embed:))]
            .compactMap { $0?.nilIfEmpty }
            .joined(separator: ", ")
            .emojiUnescapedString
            .truncated(to: 480, appending: "...")

        text = mentionPattern.replace(in: text, with: "@mention")

        guard let channelName = IRCChannelName(channelId.value) else {
            log.warning("Could not convert \(channelId.value) (maybe it is missing a leading '#'?)")
            return Promise(.failure(IRCMessageClientError.invalidChannelName(channelId.value)))
        }

        ircClient.send(.PRIVMSG([.channel(channelName)], text))

        return Promise(.success(message))
    }

    func editMessage(_ id: MessageID, on channelId: ChannelID, content: String) -> Promise<D2MessageIO.Message?, Error> {
        // TODO
        Promise(.success(nil))
    }

    func deleteMessage(_ id: MessageID, on channelId: ChannelID) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    func bulkDeleteMessages(_ ids: [MessageID], on channelId: ChannelID) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    func getMessages(for channelId: ChannelID, limit: Int, selection: MessageSelection?) -> Promise<[D2MessageIO.Message], Error> {
        // TODO
        Promise(.success([]))
    }

    func isGuildTextChannel(_ channelId: ChannelID) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    func isDMTextChannel(_ channelId: ChannelID) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    func triggerTyping(on channelId: ChannelID) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }

    func createReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) -> Promise<D2MessageIO.Message?, Error> {
        // TODO
        Promise(.success(nil))
    }

    func createEmoji(on guildId: GuildID, name: String, image: String, roles: [RoleID]) -> Promise<D2MessageIO.Emoji?, Error> {
        // TODO
        Promise(.success(nil))
    }

    func deleteEmoji(from guildId: GuildID, emojiId: EmojiID) -> Promise<Bool, Error> {
        // TODO
        Promise(.success(false))
    }
}
