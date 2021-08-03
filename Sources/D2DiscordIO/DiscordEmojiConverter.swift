import D2MessageIO
import Discord

// FROM Discord conversions

extension DiscordEmoji: MessageIOConvertible {
    public var usingMessageIO: Emoji {
        Emoji(
            id: id?.usingMessageIO,
            managed: managed ?? false,
            animated: animated ?? false,
            name: name,
            requireColons: requireColons ?? false,
            roles: roles?.usingMessageIO ?? []
        )
    }
}
