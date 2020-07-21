public struct OpenTDBResponse: Codable {
    public enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }

    public let responseCode: Int
    public let results: [Trivia]

    public struct Trivia: Codable {
        public enum CodingKeys: String, CodingKey {
            case category
            case type
            case difficulty
            case question
            case correctAnswer = "correct_answer"
            case incorrectAnswers = "incorrect_answers"
        }

        public let category: String
        public let type: String
        public let difficulty: String
        public let question: String
        public let correctAnswer: String
        public let incorrectAnswers: [String]

        public var allAnswers: [String] { [correctAnswer] + incorrectAnswers }
    }
}
