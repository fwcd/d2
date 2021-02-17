public enum AkinatorResponse {
    public typealias NewGame = Basic<NewGameParameters>
    public typealias StepInformation = Basic<StepInformationParameters>

    public struct Basic<T>: Codable where T: Codable {
        public let completion: String
        public let parameters: T
    }

    public struct Identification: Codable {
        public let channel: Int
        public let session: String
        public let signature: String
    }

    public struct StepInformationParameters: Codable {
        public let question: String
        public let answers: [Answer]
        public let step: Int
        public let progression: Double
        public let questionid: Int

        public var asQuestion: AkinatorQuestion {
            AkinatorQuestion(text: question, progression: progression, step: step)
        }

        public struct Answer: Codable {
            public let answer: String
        }
    }

    public struct NewGameParameters: Codable {
        public enum CodingKeys: String, CodingKey {
            case identification
            case stepInformation = "step_information"
        }

        public let identification: Identification
        public let stepInformation: StepInformationParameters
    }
}
