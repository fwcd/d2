import D2MessageIO
import Utils

public struct ReactionTrigger {
    let emoji: (Message) -> Promise<String, Error>

    public init(emoji: @escaping (Message) -> Promise<String, Error>) {
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
            Promise.catching {
                guard Double.random(in: 0..<1) < probability else { throw ReactionTriggerError.notFeelingLucky }
                guard authorNames.map({ $0.contains(message.author?.username.lowercased() ?? "") }) ?? true else { throw ReactionTriggerError.mismatchingAuthor }
                guard messageTypes.flatMap({ message.type.map($0.contains) }) ?? true else { throw ReactionTriggerError.mismatchingMessageType }
                guard keywords.map({ $0.contains(where: message.content.lowercased().contains) }) ?? true else { throw ReactionTriggerError.mismatchingKeywords }
                return emoji
            }
        }
    }
}
