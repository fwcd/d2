import Discord
import D2MessageIO

// TO Discord conversions

extension InteractionResponse: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordInteractionResponse {
        DiscordInteractionResponse(
            type: type.usingDiscordAPI,
            data: DiscordInteractionApplicationCommandCallbackData(
                tts: data?.tts,
                content: data?.content,
                embeds: data?.embeds.usingDiscordAPI
            )
        )
    }
}

extension InteractionResponse.ResponseType: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordInteractionResponseType {
        switch self {
            case .pong: .pong
            case .acknowledge: .acknowledge
            case .channelMessage: .channelMessage
            case .channelMessageWithSource: .channelMessageWithSource
            case .ackWithSource: .ackWithSource
        }
    }
}
