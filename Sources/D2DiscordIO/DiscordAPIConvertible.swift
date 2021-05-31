import Discord
import D2MessageIO
import Utils

protocol DiscordAPIConvertible {
    associatedtype DiscordAPIType

    var usingDiscordAPI: DiscordAPIType { get }
}

extension Dictionary: DiscordAPIConvertible where Key: DiscordAPIConvertible, Value: DiscordAPIConvertible, Key.DiscordAPIType: Hashable {
    var usingDiscordAPI: [Key.DiscordAPIType: Value.DiscordAPIType] {
        return [Key.DiscordAPIType: Value.DiscordAPIType](uniqueKeysWithValues: map { ($0.usingDiscordAPI, $1.usingDiscordAPI) })
    }
}

extension DiscordLazyDictionary: MessageIOConvertible where K: MessageIOConvertible, V: MessageIOConvertible, K.MessageIOType: Hashable {
    public var usingMessageIO: LazyDictionary<K.MessageIOType, V.MessageIOType> {
        var dict: LazyDictionary<K.MessageIOType, V.MessageIOType> = [:]
        for key in keys {
            dict[lazy: key.usingMessageIO] = .lazy { self[key]?.usingMessageIO }
        }
        return dict
    }
}

extension LazyDictionary: DiscordAPIConvertible where K: DiscordAPIConvertible, V: DiscordAPIConvertible, K.DiscordAPIType: Hashable {
    var usingDiscordAPI: DiscordLazyDictionary<K.DiscordAPIType, V.DiscordAPIType> {
        var dict: DiscordLazyDictionary<K.DiscordAPIType, V.DiscordAPIType> = [:]
        for key in keys {
            dict[lazy: key.usingDiscordAPI] = keys.contains(key) ? .lazy { self[key]!.usingDiscordAPI } : nil
        }
        return dict
    }
}

extension Array: DiscordAPIConvertible where Element: DiscordAPIConvertible {
    var usingDiscordAPI: [Element.DiscordAPIType] {
        return map { $0.usingDiscordAPI }
    }
}
