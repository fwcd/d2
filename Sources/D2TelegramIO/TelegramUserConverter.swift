import D2MessageIO
import Telegrammer

// FROM Telegram conversions

extension Telegrammer.User: MessageIOConvertible {
    public var usingMessageIO: D2MessageIO.User {
        .init(
            bot: isBot,
            id: id.usingMessageIO,
            username: username ?? ""
        )
    }
}
