import D2MessageIO
import Telegrammer

// FROM Telegram conversions

extension Int64: MessageIOConvertible {
    public var usingMessageIO: ID {
        return ID(self, clientName: telegramClientName)
    }
}

// TO Telegram conversions

extension ID: TelegramAPIConvertible {
    public var usingTelegramAPI: Int64 {
        guard clientName == telegramClientName else {
			fatalError("Tried to convert non-Telegram ID to Telegram API representation: \(self)")
        }
        return base(as: Int64.self)
    }
}
