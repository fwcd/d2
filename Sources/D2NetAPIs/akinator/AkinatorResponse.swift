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
        public let step: String
        public let progression: String
        public let questionid: String

        public func asQuestion() throws -> AkinatorQuestion {
            guard let step = Int(self.step) else { throw AkinatorError.invalidStep(self.step) }
            guard let progression = Double(self.progression) else { throw AkinatorError.invalidProgression(self.progression) }
            return AkinatorQuestion(text: question, progression: progression, step: step)
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
