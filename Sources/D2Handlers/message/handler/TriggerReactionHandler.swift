import Foundation
import D2Commands
import D2MessageIO
import D2NetAPIs
import Utils

fileprivate let goodMorningPattern = try! Regex(from: "\\bg(?:u+te+n|oo+d+)\\s+mo+(?:rni+ng|(?:rge+|i+)n)\\b", caseSensitive: false)

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
            .init(probability: 0.0001, emoji: "🛸"),
            .init { message in
                Promise.catchingThen {
                    guard goodMorningPattern.matchCount(in: message.content) > 0 else { throw ReactionTriggerError.mismatchingKeywords }

                    let calendar = Calendar.current
                    let todayComponents = calendar.dateComponents([.month, .day], from: Date())

                    // Check for a special day
                    switch (todayComponents.month, todayComponents.day) {
                    // Valentine's Day
                    case (2, 14): return Promise("💘")
                    // Pi Day
                    case (3, 14): return Promise("🥧")
                    // St Patrick's Day
                    case (3, 17): return Promise("🍀")
                    // Halloween
                    case (10, 31): return Promise("🎃")
                    // Christmas
                    case (12, 24), (12, 25), (12, 26): return Promise("🎅")
                    // New Year's Eve
                    case (12, 31), (1, 1): return Promise("🎆")
                    default: break
                    }

                    // Check for guild birthday
                    if let guild = message.guild, let birthDate = guild.ownerId.flatMap({ guild.members[$0] })?.joinedAt {
                        let birthDateComponents = calendar.dateComponents([.month, .day], from: birthDate)
                        if birthDateComponents.month == todayComponents.month && birthDateComponents.day == todayComponents.day {
                            return Promise("🎂")
                        }
                    }

                    // React with the weather
                    guard let city = cityConfig.wrappedValue.city else { throw ReactionTriggerError.other("No city specified") }
                    return OpenWeatherMapQuery(city: city).perform()
                        .mapCatching {
                            guard let emoji = $0.emoji else { throw ReactionTriggerError.other("No weather emoji") }
                            return emoji
                        }
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
        }
        return false
    }
}
