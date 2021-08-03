import Discord
import D2MessageIO

// TO Discord conversions

extension ChannelModification: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordEndpoint.Options.ModifyChannel {
        .init(
            name: name,
            archived: archived,
            locked: locked
        )
    }
}
