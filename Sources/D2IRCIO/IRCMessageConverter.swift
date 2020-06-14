import D2MessageIO
import Emoji
import IRC

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
