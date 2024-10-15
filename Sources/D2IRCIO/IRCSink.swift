import Foundation
import D2MessageIO
import Utils
import Emoji
import IRC
import Logging

fileprivate let log = Logger(label: "D2IRCIO.IRCSink")
nonisolated(unsafe) private let mentionPattern = #/<@.+?>/#

struct IRCSink: DefaultSink {
    private let client: IRCClient

    let name: String

    init(client: IRCClient, name: String) {
        self.client = client
        self.name = name
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

    func sendMessage(_ message: D2MessageIO.Message, to channelId: ChannelID) throws -> D2MessageIO.Message? {
        log.debug("Sending message '\(message.content)'")

        var text = [message.content, message.embed.map(flatten(embed:))]
            .compactMap { $0?.nilIfEmpty }
            .joined(separator: ", ")
            .emojiUnescapedString
            .truncated(to: 480, appending: "...")

        text = text.replacing(mentionPattern, with: "@mention")

        guard let channelName = IRCChannelName(channelId.value) else {
            log.warning("Could not convert \(channelId.value) (maybe it is missing a leading '#'?)")
            throw IRCSinkError.invalidChannelName(channelId.value)
        }

        client.send(.PRIVMSG([.channel(channelName)], text))

        return message
    }
}
