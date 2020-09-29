import D2MessageIO
import Utils

protocol IRCAPIConvertible {
    associatedtype IRCAPIType

    var usingIRCAPI: IRCAPIType { get }
}

extension Dictionary: IRCAPIConvertible where Key: IRCAPIConvertible, Value: IRCAPIConvertible, Key.IRCAPIType: Hashable {
    var usingIRCAPI: [Key.IRCAPIType: Value.IRCAPIType] {
        return [Key.IRCAPIType: Value.IRCAPIType](uniqueKeysWithValues: map { ($0.usingIRCAPI, $1.usingIRCAPI) })
    }
}

extension Array: IRCAPIConvertible where Element: IRCAPIConvertible {
    var usingIRCAPI: [Element.IRCAPIType] {
        return map { $0.usingIRCAPI }
    }
}
