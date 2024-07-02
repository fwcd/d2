import D2MessageIO
import Logging

private let log = Logger(label: "D2Handlers.MentionSomeoneHandler")

public struct MentionSomeoneHandler: MessageHandler {
    private let rewriter = MentionSomeoneRewriter()

    public func handleRaw(message: Message, sink: any Sink) async -> Bool {
        if let rewrite = rewriter.rewrite(message: message, sink: sink), let channelId = message.channelId {
            do {
                try await sink.sendMessage(Message(content: rewrite.mentions.map { "<@\($0.id)>" }.joined(separator: " ")), to: channelId)
            } catch {
                log.warning("Could not send @someone response: \(error)")
            }
            return true
        } else {
            return false
        }
    }
}
