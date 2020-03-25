import D2MessageIO
import Telegrammer

// FROM Telegram conversions

extension Telegrammer.Message: MessageIOConvertible {
    public var usingMessageIO: D2MessageIO.Message {
        .init(
            content: text ?? "",
            author: from?.usingMessageIO,
            channelId: chat.id.usingMessageIO
        ) // TODO: Convert attachments/files
    }
}
