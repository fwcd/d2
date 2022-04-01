import D2Commands
import D2MessageIO
import Utils

public struct TriggerReactionHandler: MessageHandler {
    private let keywords: [String: String]

    public init(keywords: [String: String] = [
        "hello": "👋",
        "hmmm": "🤔",
        "hai": "🦈",
        "spooky": "🎃",
        "ghost": "👻"
    ]) {
        self.keywords = keywords
    }

    public func handle(message: Message, from client: any MessageClient) -> Bool {
        if let emoji = keywords[message.content.lowercased()], let messageId = message.id, let channelId = message.channelId {
            client.createReaction(for: messageId, on: channelId, emoji: emoji)
            return true
        }
        return false
    }
}
