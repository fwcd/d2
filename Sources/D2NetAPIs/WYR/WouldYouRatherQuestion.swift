public struct WouldYouRatherQuestion: Sendable {
    public let title: String
    public let firstChoice: String
    public let secondChoice: String
    public let explanation: String?

    public init(
        title: String,
        firstChoice: String,
        secondChoice: String,
        explanation: String? = nil
    ) {
        self.title = title
        self.firstChoice = firstChoice
        self.secondChoice = secondChoice
        self.explanation = explanation
    }
}
