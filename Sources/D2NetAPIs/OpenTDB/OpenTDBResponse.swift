public struct OpenTDBResponse: Sendable, Codable {
    public enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }

    public let responseCode: Int
    public var results: [Trivia]

    public struct Trivia: Sendable, Codable {
        public enum CodingKeys: String, CodingKey {
            case category
            case type
            case difficulty
            case question
            case correctAnswer = "correct_answer"
            case incorrectAnswers = "incorrect_answers"
        }

        public var category: String
        public var type: String
        public var difficulty: String
        public var question: String
        public var correctAnswer: String
        public var incorrectAnswers: [String]

        public var allAnswers: [String] { [correctAnswer] + incorrectAnswers }
    }
}
