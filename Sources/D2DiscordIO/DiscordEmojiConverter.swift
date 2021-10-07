import D2MessageIO
import Discord

// TO Discord conversions

extension Emoji: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordEmoji {
        DiscordEmoji(
            id: id?.usingDiscordAPI,
            managed: managed,
            animated: animated,
            name: name,
            requireColons: requireColons,
            roles: roles.usingDiscordAPI
        )
    }
}

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
