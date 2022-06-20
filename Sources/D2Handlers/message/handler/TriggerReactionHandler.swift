import D2Commands
import D2MessageIO
import D2NetAPIs
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
            .init { message in
                Promise.catching {
                    guard ["good morning", "guten morgen"].contains(where: message.content.lowercased().contains) else { throw ReactionTriggerError.mismatchingKeywords }
                    guard let city = cityConfig.wrappedValue.city else { throw ReactionTriggerError.other("No city specified") }
                    return city
                }
                .then { OpenWeatherMapQuery(city: $0).perform() }
                .mapCatching {
                    guard let emoji = $0.emoji else { throw ReactionTriggerError.other("No weather emoji") }
                    return emoji
                }
            }
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
