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
        "the": "th'",
        "my": "me",
        "and": "'n",
        "as": "'s",
        "of": "o'",
        "\\bthose\\b": "'ose",
        "\\bwhoa\\b": "avast",
        "\\bvery\\b": "mighty",
        "ng\\b": "n'",
        "ngs\\b": "n's",
        "st\\b": "s'",
        "you": "ye",
        "\\bto": "t'",
        "\\bis": "be"
    ]) {
        self.substitutions = substitutions
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter some text!")
            return
        }

        let result = substitutions.reduce(input) { $0.replacingOccurrences(of: $1.key, with: $1.value, options: [.caseInsensitive, .regularExpression]) }
        output.append(result.replacingOccurrences(of: ".", with: ". Arr!"))
    }
}
