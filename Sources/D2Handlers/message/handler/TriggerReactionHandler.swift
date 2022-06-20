import D2Commands
import D2MessageIO
import Utils

public struct TriggerReactionHandler: MessageHandler {
    private let triggers: [ReactionTrigger]

    public init(cityConfig: AutoSerializing<CityConfiguration>, triggers: [ReactionTrigger]? = nil) {
        self.triggers = triggers ?? [
            .init(keywords: ["hello"], emoji: "👋"),
            .init(keywords: ["hmmm"], emoji: "🤔"),
            .init(keywords: ["hai"], emoji: "🦈"),
            .init(keywords: ["spooky"], emoji: "🎃"),
            .init(keywords: ["ghost"], emoji: "👻"),
            .init(authorNames: ["sep", "lord_constantin"], messageTypes: [.guildMemberJoin], emoji: "♾️"),
            .init(messageTypes: [.userPremiumGuildSubscription], emoji: "💎"),
        ]
    }

    public func handle(message: Message, from client: any MessageClient) -> Bool {
        if let messageId = message.id, let channelId = message.channelId {
            for trigger in triggers {
                trigger.emoji(message).listen {
                    if case let .success(emoji) = $0 {
                        client.createReaction(for: messageId, on: channelId, emoji: emoji)
                    }
                }
            }
            return true
        }
        return false
    }
}
