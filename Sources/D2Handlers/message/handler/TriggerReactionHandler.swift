import D2Commands
import D2MessageIO
import Utils

public struct TriggerReactionHandler: MessageHandler {
    private let triggers: [ReactionTrigger]

    public init(triggers: [ReactionTrigger] = [
        .init(keywords: ["hello"], emoji: "👋"),
        .init(keywords: ["hmmm"], emoji: "🤔"),
        .init(keywords: ["hai"], emoji: "🦈"),
        .init(keywords: ["spooky"], emoji: "🎃"),
        .init(keywords: ["ghost"], emoji: "👻"),
        .init(keywords: ["good morning", "guten morgen"], emoji: "☀️"),
    ]) {
        self.triggers = triggers
    }

    public func handle(message: Message, from client: any MessageClient) -> Bool {
        if let messageId = message.id, let channelId = message.channelId {
            for trigger in triggers where trigger.matches(content: message.content) {
                client.createReaction(for: messageId, on: channelId, emoji: trigger.emoji)
            }
            return true
        }
        return false
    }
}
