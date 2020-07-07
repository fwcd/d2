import D2MessageIO

public struct MentionSomeoneHandler: MessageHandler {
    private let rewriter = MentionSomeoneRewriter()

    public func handleRaw(message: Message, from client: MessageClient) -> Bool {
        if let rewrite = rewriter.rewrite(message: message, from: client), let channelId = message.channelId {
            client.sendMessage(Message(content: rewrite.mentions.map { "<@\($0.id)>" }.joined(separator: " ")), to: channelId)
            return true
        } else {
            return false
        }
    }
}