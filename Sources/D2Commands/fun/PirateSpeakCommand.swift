public class PirateSpeakCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Converts some text into Pirate speak",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text
    private let substitutions: [String: String]

    public init(substitutions: [String: String] = [
        "hello": "ahoy",
        "yes": "aye",
        "this": "'tis",
        "whoa": "avast",
        "very": "mighty",
        "ing": "in'",
        "you": "ye",
        "the": "t'",
        "is": "be"
    ]) {
        self.substitutions = substitutions
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter some text!")
            return
        }

        let result = substitutions.reduce(input) { $0.replacingOccurrences(of: $1.key, with: $1.value, options: .caseInsensitive) }
        output.append(result)
    }
}
