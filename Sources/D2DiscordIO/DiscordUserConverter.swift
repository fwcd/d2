import D2MessageIO
import Discord

// FROM Discord conversions

extension DiscordUser: MessageIOConvertible {
    public var usingMessageIO: User {
        User(
            avatar: avatar ?? "",
            bot: bot ?? false,
            discriminator: discriminator ?? "",
            email: email ?? "",
            id: id.usingMessageIO,
            mfaEnabled: mfaEnabled ?? false,
            username: username ?? "",
            verified: verified ?? false
        )
    }
}
