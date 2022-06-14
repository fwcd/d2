public struct ReactionTrigger {
    private let keywords: [String]
    private let probability: Double
    let emoji: String

    public init(keywords: [String], probability: Double = 1, emoji: String) {
        self.keywords = keywords
        self.probability = probability
        self.emoji = emoji
    }

    func matches(content: String) -> Bool {
        guard Double.random(in: 0..<1) < probability else { return false }
        let lowered = content.lowercased()
        return keywords.contains(where: lowered.contains)
    }
}
