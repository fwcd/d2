import D2MessageIO
import Discord

// FROM Discord conversions

extension DiscordEmoji: MessageIOConvertible {
    public var usingMessageIO: Emoji {
        return Emoji(
            id: id?.usingMessageIO,
            managed: managed,
            animated: animated,
            name: name,
            requireColons: requireColons,
            roles: roles.map { $0.usingMessageIO }
        )
    }
}
