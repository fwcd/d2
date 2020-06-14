import D2MessageIO
import Emoji
import IRC

// FROM IRC conversions

extension IRCMessage { // not MessageIOConvertible, since it does not support optionality
    public var usingMessageIO: D2MessageIO.Message? {
        guard case let .PRIVMSG(recipients, content) = command,
            case let .channel(channelName)? = recipients.first else { return nil }
        // TODO: Support chats with multiple recipients and .nickname()
        return D2MessageIO.Message(
            content: content,
            // TODO: Proper user IDs
            author: User(id: dummyId, username: (origin?.split(separator: "!").first).map { String($0) } ?? "?"),
            channelId: channelName.usingMessageIO
        )
    }
}

// TO IRC conversions
    
private func flatten(embed: Embed) -> String {
    let lines: [String?] = [
        embed.title.flatMap { title in embed.url.map { "[\(title)](\($0.absoluteString))" } ?? title },
        embed.description
    ] + embed.fields.flatMap { ["**\($0.name)**", $0.value] } + [
        embed.footer?.text
    ]
    return lines
        .compactMap { $0 }
        .joined(separator: "\n")
}

extension D2MessageIO.Message: IRCAPIConvertible {
    public var usingIRCAPI: IRCMessage {
        let text = [content, embed.map(flatten(embed:))]
            .compactMap { $0?.nilIfEmpty }
            .joined(separator: "\n")
            .emojiUnescapedString
        return IRCMessage(command: .PRIVMSG(channelId.map { [.channel($0.usingIRCAPI)] } ?? [], text))
    }
}
