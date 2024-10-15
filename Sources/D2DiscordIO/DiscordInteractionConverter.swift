import Discord
import D2MessageIO

// FROM Discord conversions

extension DiscordInteraction {
    public func usingMessageIO(with sink: any Sink) async -> Interaction {
        await Interaction(
            id: id.usingMessageIO,
            type: type?.usingMessageIO,
            data: data?.usingMessageIO,
            guildId: guildId.usingMessageIO,
            channelId: channelId.usingMessageIO,
            member: member?.usingMessageIO(in: guildId.usingMessageIO),
            message: message?.usingMessageIO(with: sink),
            token: token,
            version: version
        )
    }
}

extension DiscordInteractionType: MessageIOConvertible {
    public var usingMessageIO: Interaction.InteractionType? {
        switch self {
            case .ping: .ping
            case .applicationCommand: .mioCommand
            case .messageComponent: .messageComponent
            default: nil
        }
    }
}

extension DiscordInteractionData: MessageIOConvertible {
    public var usingMessageIO: Interaction.InteractionData {
        .init(
            id: id?.usingMessageIO,
            name: name ?? "",
            customId: customId,
            options: options?.usingMessageIO ?? []
        )
    }
}

extension DiscordInteractionDataOption: MessageIOConvertible {
    public var usingMessageIO: Interaction.InteractionData.Option {
        .init(
            name: name,
            options: options?.usingMessageIO ?? []
        )
    }
}
