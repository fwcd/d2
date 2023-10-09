import Foundation
import D2MessageIO
import Utils
import Emoji
import IRC
import Logging

fileprivate let log = Logger(label: "D2IRCIO.IRCSink")
fileprivate let mentionPattern = try! Regex(from: "<@.+?>")

struct IRCSink: DefaultSink {
    private let ircClient: IRCClient

    let name: String

    init(ircClient: IRCClient, name: String) {
        self.ircClient = ircClient
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

    func sendMessage(_ message: D2MessageIO.Message, to channelId: ChannelID) -> Promise<D2MessageIO.Message?, any Error> {
        log.debug("Sending message '\(message.content)'")

        var text = [message.content, message.embed.map(flatten(embed:))]
            .compactMap { $0?.nilIfEmpty }
            .joined(separator: ", ")
            .emojiUnescapedString
            .truncated(to: 480, appending: "...")

        text = mentionPattern.replace(in: text, with: "@mention")

        guard let channelName = IRCChannelName(channelId.value) else {
            log.warning("Could not convert \(channelId.value) (maybe it is missing a leading '#'?)")
            return Promise(.failure(IRCSinkError.invalidChannelName(channelId.value)))
        }

        ircClient.send(.PRIVMSG([.channel(channelName)], text))

        return Promise(.success(message))
    }
}
