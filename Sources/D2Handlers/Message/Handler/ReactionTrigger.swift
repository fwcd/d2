import D2MessageIO
import Utils

public struct ReactionTrigger {
    let emoji: (Message) async throws -> String

    public init(emoji: @escaping (Message) async throws -> String) {
        self.emoji = emoji
    }

    public init(
        keywords: Set<String>? = nil,
        authorNames: Set<String>? = nil,
        messageTypes: Set<Message.MessageType>? = nil,
        probability: Double = 1,
        emoji: String
    ) {
        self.init { message in
            guard Double.random(in: 0..<1) < probability else { throw ReactionTriggerError.notFeelingLucky }
            guard authorNames.map({ $0.contains(message.author?.username.lowercased() ?? "") }) ?? true else { throw ReactionTriggerError.mismatchingAuthor }
            guard messageTypes.flatMap({ message.type.map($0.contains) }) ?? true else { throw ReactionTriggerError.mismatchingMessageType }
            let regex = try! LegacyRegex(
                from: "\\b(?:\((keywords ?? []).map(LegacyRegex.escape).joined(separator: "|")))\\b",
                caseSensitive: false
            )
            guard regex.matchCount(in: message.content) > 0 else { throw ReactionTriggerError.mismatchingKeywords }
            return emoji
        }
    }
}
