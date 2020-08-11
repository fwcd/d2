public class Magic8BallCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Answers a yes/no question",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text
    public let answers: [Decision: [String]]

    public enum Decision: Int, CaseIterable, Comparable {
        case yes = 0
        case undecided = 1
        case no = 2

        public static func <(lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    public init(answers: [Decision: [String]] = [
        .yes: [
            "It is certain.",
            "It is decidedly so",
            "Without a doubt.",
            "Yes - definitely.",
            "You may rely on it.",
            "As I see it, yes.",
            "Most likely.",
            "Outlook good.",
            "Yes.",
            "Signs point to yes."
        ],
        .undecided: [
            "Reply hazy, try again.",
            "Ask again later.",
            "Better not tell you now.",
            "Cannot predict now.",
            "Concentrate and ask again."
        ],
        .no: [
            "Don't count on it.",
            "My reply is no.",
            "My sources say no.",
            "Outlook not so good.",
            "Very doubtful."
        ]
    ]) {
        self.answers = answers
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        var hasher = Hasher()
        hasher.combine(normalize(input: input))
        let decisions = Decision.allCases.sorted()
        let i = abs(hasher.finalize()) % decisions.count
        let decision = decisions[i]
        output.append(answers[decision]?.randomElement() ?? "I am not sure about that!")
    }

    private func normalize(input: String) -> some Hashable {
        // Make the input case-, space- and translation-invariant
        Set(input.lowercased().split(separator: " "))
    }
}
