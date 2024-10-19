import Discord
import D2MessageIO

// FROM Discord conversions

extension DiscordReadyEvent: MessageIOConvertible {
    public var usingMessageIO: ReadyEvent {
        ReadyEvent(
            gatewayVersion: gatewayVersion,
            shard: shard
        )
    }
}
