public struct WouldYouRatherQuestion {
    public let firstChoice: String
    public let secondChoice: String
    public let explanation: String?

    public init(
        firstChoice: String,
        secondChoice: String,
        explanation: String? = nil
    ) {
        self.firstChoice = firstChoice
        self.secondChoice = secondChoice
        self.explanation = explanation
    }
}
