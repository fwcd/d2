import Foundation
import D2Commands
import D2MessageIO
import D2NetAPIs
import Utils

fileprivate let goodMorningOrEveningPattern = try! Regex(from: "\\bg(?:u+te+n?|oo+d+)\\s+(?:mo+(?:rni+ng|(?:rge+|i+)n)|e+ve+ni+ng|a+be+nd|da+y|ta+g|n(?:a+ch|i+gh)t)\\b", caseSensitive: false)

public struct TriggerReactionHandler: MessageHandler {
    private let triggers: [ReactionTrigger]

    public init(triggers: [ReactionTrigger]) {
        self.triggers = triggers
    }

    public init(
        dateSpecificReactions: Bool = true,
        weatherReactions: Bool = true,
        cityConfiguration: AutoSerializing<CityConfiguration>
    ) {
        self.init(
            dateSpecificReactions: dateSpecificReactions,
            weatherReactions: weatherReactions,
            weatherEmojiProvider: {
                guard let city = cityConfiguration.wrappedValue.city else { throw ReactionTriggerError.other("No city specified") }
                return OpenWeatherMapQuery(city: city).perform()
                    .mapCatching {
                        guard let emoji = $0.emoji else { throw ReactionTriggerError.other("No weather emoji") }
                        return emoji
                    }
            }
        )
    }

    public init(
        dateSpecificReactions: Bool = true,
        weatherReactions: Bool = true,
        weatherEmojiProvider: @escaping () throws -> Promise<String, any Error>
    ) {
        self.init(triggers: [
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
                    guard goodMorningOrEveningPattern.matchCount(in: message.content) > 0 else { throw ReactionTriggerError.mismatchingKeywords }

                    if dateSpecificReactions {
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
                    }

                    if weatherReactions {
                        return try weatherEmojiProvider()
                    }

                    throw ReactionTriggerError.other("No good morning/evening reaction configured")
                }
            }
        ])
    }

    public func handle(message: Message, sink: any Sink) -> Bool {
        if let messageId = message.id, let channelId = message.channelId {
            for trigger in triggers {
                trigger.emoji(message).listen {
                    if case let .success(emoji) = $0 {
                        sink.createReaction(for: messageId, on: channelId, emoji: emoji)
                    }
                }
            }
        }
        return false
    }
}
