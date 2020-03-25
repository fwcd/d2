import D2MessageIO
import TelegramBotSDK

// FROM Telegram conversions

extension TelegramBotSDK.Message: MessageIOConvertible {
    public var usingMessageIO: D2MessageIO.Message {
        .init(
            content: text ?? "",
            author: from?.usingMessageIO,
            channelId: chat.id.usingMessageIO
        ) // TODO: Convert attachments/files
    }
}
