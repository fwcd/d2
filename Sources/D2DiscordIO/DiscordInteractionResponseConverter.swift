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
            case .pong: return .pong
            case .acknowledge: return .acknowledge
            case .channelMessage: return .channelMessage
            case .channelMessageWithSource: return .channelMessageWithSource
            case .ackWithSource: return .ackWithSource
        }
    }
}
