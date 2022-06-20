import D2MessageIO

public struct ReactionTrigger {
    let emoji: (Message) -> String?

    public init(emoji: @escaping (Message) -> String?) {
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
            guard Double.random(in: 0..<1) < probability
                && authorNames.map({ $0.contains(message.author?.username.lowercased() ?? "") }) ?? true
                && messageTypes.flatMap({ message.type.map($0.contains) }) ?? true
                && keywords.map({ $0.contains(where: message.content.lowercased().contains) }) ?? true else { return nil }
            return emoji
        }
    }
}
