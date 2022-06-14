import D2Commands
import D2MessageIO
import Utils

public struct TriggerReactionHandler: MessageHandler {
    private let keywords: [[String]: String]

    public init(keywords: [[String]: String] = [
        ["hello"]: "👋",
        ["hmmm"]: "🤔",
        ["hai"]: "🦈",
        ["spooky"]: "🎃",
        ["ghost"]: "👻",
        ["good morning", "guten morgen"]: "☀️"
    ]) {
        self.keywords = keywords
    }

    public func handle(message: Message, from client: any MessageClient) -> Bool {
        if let messageId = message.id, let channelId = message.channelId {
            let lowerContent = message.content.lowercased()
            for (words, emoji) in keywords {
                if words.contains(where: lowerContent.contains) {
                    client.createReaction(for: messageId, on: channelId, emoji: emoji)
                }
            }
            return true
        }
        return false
    }
}
