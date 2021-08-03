import D2MessageIO
import Discord

// TO Discord conversions

extension Permission: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordPermissions {
        .init(rawValue: rawValue)
    }
}

// FROM Discord conversions

extension DiscordPermissions: MessageIOConvertible {
    public var usingMessageIO: Permission {
        .init(rawValue: rawValue)
    }
}
