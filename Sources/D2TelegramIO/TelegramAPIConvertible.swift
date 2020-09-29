import D2MessageIO
import Utils

protocol TelegramAPIConvertible {
    associatedtype TelegramAPIType

    var usingTelegramAPI: TelegramAPIType { get }
}

extension Dictionary: TelegramAPIConvertible where Key: TelegramAPIConvertible, Value: TelegramAPIConvertible, Key.TelegramAPIType: Hashable {
    var usingTelegramAPI: [Key.TelegramAPIType: Value.TelegramAPIType] {
        return [Key.TelegramAPIType: Value.TelegramAPIType](uniqueKeysWithValues: map { ($0.usingTelegramAPI, $1.usingTelegramAPI) })
    }
}

extension Array: TelegramAPIConvertible where Element: TelegramAPIConvertible {
    var usingTelegramAPI: [Element.TelegramAPIType] {
        return map { $0.usingTelegramAPI }
    }
}
