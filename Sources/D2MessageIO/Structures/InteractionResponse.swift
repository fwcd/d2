public struct InteractionResponse: Sendable {
    public let type: ResponseType
    public let data: Message?

    public init(type: ResponseType, data: Message? = nil) {
        self.type = type
        self.data = data
    }

    public enum ResponseType: Sendable {
        case pong
        case channelMessageWithSource
        case deferredChannelMessageWithSource
        case deferredUpdateMessage
    }
}
