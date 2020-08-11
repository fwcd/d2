public class Magic8BallCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Answers a yes/no question",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text
    public let answers: [String]

    public init(answers: [String] = [
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
        "Reply hazy, try again.",
        "Ask again later.",
        "Better not tell you now.",
        "Cannot predict now.",
        "Concentrate and ask again.",
        "Don't count on it.",
        "My reply is no.",
        "My sources say no.",
        "Outlook not so good.",
        "Very doubtful."
    ]) {
        self.answers = answers + ["I do not know how to respond to that."]
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        var hasher = Hasher()
        hasher.combine(normalize(input: input))
        let i = abs(hasher.finalize()) % answers.count
        output.append(answers[i])
    }

    private func normalize(input: String) -> some Hashable {
        // Make the input case-, space- and translation-invariant
        Set(input.lowercased().split(separator: " "))
    }
}
