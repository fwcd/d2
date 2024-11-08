import Foundation
import D2Commands
import D2MessageIO
import D2NetAPIs
import Utils
import Logging

nonisolated(unsafe) private let goodMorningOrEveningPattern = #/\b[gjm](?:j*[uü]+[ste]+n?|oo+d+)\s+(?:[gm](?:[oö]+(?:r+n+i+ng|(?:r+[gj]+(?:e+|ä+h*)|i+)n)|ü+de+)|e+ve+ni+ng|a+be+nd|da+y|ta+g|n(?:a+ch|i+gh)t)\b/#.ignoresCase()
private let log = Logger(label: "D2Handler.TriggerReactionHandler")

public struct TriggerReactionHandler: MessageHandler {
    private let triggers: [ReactionTrigger]

    public init(triggers: [ReactionTrigger]) {
        self.triggers = triggers
    }

    public init(
        @Binding configuration: TriggerReactionConfiguration,
        @Binding cityConfiguration: CityConfiguration
    ) {
        self.init(
            $configuration: $configuration,
            weatherEmojiProvider: {
                guard let city = cityConfiguration.city else { throw ReactionTriggerError.other("No city specified") }
                guard let emoji = try await OpenWeatherMapQuery(city: city).perform().emoji else { throw ReactionTriggerError.other("No weather emoji") }
                return emoji
            }
        )
    }

    public init(
        @Binding configuration: TriggerReactionConfiguration,
        weatherEmojiProvider: @escaping () async throws -> String
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
                guard !message.content.matches(of: goodMorningOrEveningPattern).isEmpty else { throw ReactionTriggerError.mismatchingKeywords }

                if configuration.dateSpecificReactions {
                    let calendar = Calendar.current
                    let todayComponents = calendar.dateComponents([.month, .day], from: Date())

                    // Check for a special day
                    switch (todayComponents.month, todayComponents.day) {
                    // Valentine's Day
                    case (2, 14): return "💘"
                    // Pi Day
                    case (3, 14): return "🥧"
                    // St Patrick's Day
                    case (3, 17): return "🍀"
                    // Halloween
                    case (10, 31): return "🎃"
                    // Christmas
                    case (12, 24), (12, 25), (12, 26): return "🎅"
                    // New Year's Eve
                    case (12, 31), (1, 1): return "🎆"
                    default: break
                    }

                    // Check for guild birthday
                    if let guild = message.guild, let birthDate = guild.ownerId.flatMap({ guild.members[$0] })?.joinedAt {
                        let birthDateComponents = calendar.dateComponents([.month, .day], from: birthDate)
                        if birthDateComponents.month == todayComponents.month && birthDateComponents.day == todayComponents.day {
                            return "🎂"
                        }
                    }
                }

                if configuration.weatherReactions {
                    return try await weatherEmojiProvider()
                }

                throw ReactionTriggerError.other("No good morning/evening reaction configured")
            }
        ])
    }

    public func handle(message: Message, sink: any Sink) async -> Bool {
        if let messageId = message.id, let channelId = message.channelId {
            for trigger in triggers {
                if let emoji = try? await trigger.emoji(message) {
                    do {
                        try await sink.createReaction(for: messageId, on: channelId, emoji: emoji)
                    } catch {
                        log.warning("Could not create triggered \(emoji) reaction on message \(messageId) in channel \(channelId): \(error)")
                    }
                }
            }
        }
        return false
    }
}
