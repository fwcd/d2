public struct BingTranslateResult: Sendable, Codable {
    public let detectedLanguage: Language?
    public let translations: [Translation]

    public struct Language: Sendable, Codable {
        public let language: String
        public let score: Double
    }

    public struct Translation: Sendable, Codable {
        public let text: String
        public let to: String
        public let sentLen: SentLen?

        public struct SentLen: Sendable, Codable {
            public let srcSentLen: [Int]
            public let transSentLen: [Int]
        }
    }
}
