import Foundation
import Utils
import D2MessageIO
import Emoji
import Telegrammer
import Logging

fileprivate let log = Logger(label: "D2TelegramIO.TelegramMessageClient")

struct TelegramMessageClient: DefaultMessageClient {
    private let bot: Bot

    var name: String { telegramClientName }

    init(bot: Bot) {
        self.bot = bot
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
            .joined(separator: "\n")
    }

    func sendMessage(_ message: D2MessageIO.Message, to channelId: ChannelID) -> Utils.Promise<D2MessageIO.Message?, Error> {
        Utils.Promise { then in
            let text = [message.content, message.embed.map(flatten(embed:))]
                .compactMap { $0?.nilIfEmpty }
                .joined(separator: "\n")
                .emojiUnescapedString
            log.debug("Sending message '\(text)'")

            do {
                try bot.sendMessage(params: .init(chatId: .chat(channelId.usingTelegramAPI), text: text, parseMode: .markdown)).whenComplete {
                    do {
                        then(.success(try $0.get().usingMessageIO))
                    } catch {
                        log.warning("Could not send message to Telegram: \(error)")
                        then(.failure(error))
                    }
                }
            } catch {
                log.warning("Could not send message to Telegram: \(error)")
                then(.failure(error))
            }
        }
    }
}
