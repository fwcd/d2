import D2MessageIO
import IRC

// TO IRC conversions

extension ID: IRCAPIConvertible {
    public var usingIRCAPI: IRCChannelName {
        IRCChannelName(value)!
    }
}
