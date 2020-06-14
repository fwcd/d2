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
        self.answers = answers
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        output.append(answers.randomElement() ?? "I do not know how to respond to that.")
    }
}
