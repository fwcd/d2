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
        .init(keywords: ["good morning", "guten morgen"], probability: 0.001, emoji: "☀️"),
        .init(authorNames: ["sep", "lord_constantin"], messageTypes: [.guildMemberJoin], emoji: "♾️"),
        .init(messageTypes: [.userPremiumGuildSubscription], emoji: "💎"),
    ]) {
        self.triggers = triggers
    }

    public func handle(message: Message, from client: any MessageClient) -> Bool {
        if let messageId = message.id, let channelId = message.channelId {
            for trigger in triggers where trigger.matches(message: message) {
                client.createReaction(for: messageId, on: channelId, emoji: trigger.emoji)
            }
            return true
        }
        return false
    }
}
