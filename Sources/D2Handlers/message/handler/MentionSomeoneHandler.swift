import D2MessageIO

public struct MentionSomeoneHandler: MessageHandler {
    private let rewriter = MentionSomeoneRewriter()

    public func handleRaw(message: Message, sink: any Sink) -> Bool {
        if let rewrite = rewriter.rewrite(message: message, sink: sink), let channelId = message.channelId {
            sink.sendMessage(Message(content: rewrite.mentions.map { "<@\($0.id)>" }.joined(separator: " ")), to: channelId)
            return true
        } else {
            return false
        }
    }
}
