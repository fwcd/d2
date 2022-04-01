import D2MessageIO

public class Magic8BallCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Answers a yes/no question",
        presented: true,
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
            "Signs point to yes.",
            "Of course!",
            "Yep.",
            "Agreed."
        ],
        .undecided: [
            "I don't know, sorry.",
            "I know the answer, but I'm afraid, I can't tell you.",
            "Please ask a different question."
        ],
        .no: [
            "Don't count on it.",
            "Don't.",
            "My reply is no.",
            "My sources say no.",
            "Outlook not so good.",
            "Very doubtful.",
            "No.",
            "Nope.",
            "Denied."
        ]
    ]) {
        self.answers = answers
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        var hasher = Hasher()
        hasher.combine(normalize(input: input))
        let decisions = Decision.allCases.sorted()
        let i = abs(hasher.finalize()) % decisions.count
        let decision = decisions[i]
        let answer = Double.random(in: 0..<1) < 0.95
            ? answers[decision]?.randomElement() ?? "I am not sure about that!"
            : "Concentrate and ask again!"
        output.append(Embed(
            description: ":8ball: **\(answer)**"
        ))
    }

    private func normalize(input: String) -> some Hashable {
        // Make the input case-, space- and translation-invariant
        Set(input.lowercased().split(separator: " "))
    }
}
