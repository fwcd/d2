public struct BingTranslateResult: Codable {
    public let detectedLanguage: Language?
    public let translations: [Translation]

    public struct Language: Codable {
        public let language: String
        public let score: Double
    }

    public struct Translation: Codable {
        public let text: String
        public let to: String
        public let sentLen: SentLen?

        public struct SentLen: Codable {
            public let srcSentLen: [Int]
            public let transSentLen: [Int]
        }
    }
}
