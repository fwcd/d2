import SwiftDiscord
import D2MessageIO

// FROM Discord conversions

extension DiscordInteraction: MessageIOConvertible {
    public var usingMessageIO: Interaction {
        Interaction(
            id: id.usingMessageIO,
            type: type?.usingMessageIO,
            data: data?.usingMessageIO,
            guildId: guildId.usingMessageIO,
            channelId: channelId.usingMessageIO,
            member: member?.usingMessageIO,
            token: token,
            version: version
        )
    }
}

extension DiscordInteractionType: MessageIOConvertible {
    public var usingMessageIO: Interaction.InteractionType {
        switch self {
            case .ping: return .ping
            case .applicationCommand: return .mioCommand
        }
    }
}
