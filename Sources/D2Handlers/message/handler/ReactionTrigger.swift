import D2MessageIO

public struct ReactionTrigger {
    private let keywords: Set<String>
    private let authorNames: Set<String>?
    private let messageTypes: Set<Message.MessageType>?
    private let probability: Double
    let emoji: String

    public init(
        keywords: Set<String>,
        authorNames: Set<String>? = nil,
        messageTypes: Set<Message.MessageType>? = nil,
        probability: Double = 1,
        emoji: String
    ) {
        self.keywords = keywords
        self.authorNames = authorNames
        self.messageTypes = messageTypes
        self.probability = probability
        self.emoji = emoji
    }

    func matches(message: Message) -> Bool {
        guard Double.random(in: 0..<1) < probability,
              authorNames.map({ $0.contains(message.authorDisplayName.lowercased()) }) ?? true,
              messageTypes.flatMap({ message.type.map($0.contains) }) ?? true else { return false }
        let lowered = message.content.lowercased()
        return keywords.contains(where: lowered.contains)
    }
}
