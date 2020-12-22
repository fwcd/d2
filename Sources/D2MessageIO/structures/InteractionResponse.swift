public struct InteractionResponse {
    public let type: ResponseType
    public let data: Message?

    public init(type: ResponseType, data: Message? = nil) {
        self.type = type
        self.data = data
    }

    public enum ResponseType {
        case pong
        case acknowledge
        case channelMessage
        case channelMessageWithSource
        case ackWithSource
    }
}
