import D2MessageIO
import Discord

// TO Discord conversions

extension Permission: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordPermission {
        .init(rawValue: rawValue)
    }
}

// FROM Discord conversions

extension DiscordPermission: MessageIOConvertible {
    public var usingMessageIO: Permission {
        .init(rawValue: rawValue)
    }
}
