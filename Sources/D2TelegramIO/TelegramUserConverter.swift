import D2MessageIO
import TelegramBotSDK

// FROM Telegram conversions

extension TelegramBotSDK.User: MessageIOConvertible {
    public var usingMessageIO: D2MessageIO.User {
        .init(
            bot: isBot,
            id: id.usingMessageIO,
            username: username ?? ""
        )
    }
}
