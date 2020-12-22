import SwiftDiscord
import D2MessageIO

// FROM Discord conversions

extension DiscordApplicationCommandInteractionData: MessageIOConvertible {
    public var usingMessageIO: MIOCommand.InteractionData {
        MIOCommand.InteractionData(
            id: id.usingMessageIO,
            name: name,
            options: options.usingMessageIO
        )
    }
}

extension DiscordApplicationCommandInteractionDataOption: MessageIOConvertible {
    public var usingMessageIO: MIOCommand.InteractionData.Option {
        MIOCommand.InteractionData.Option(
            name: name,
            value: value,
            options: options?.usingMessageIO ?? []
        )
    }
}
