import D2Utils

fileprivate let punctuationPattern = try! Regex(from: "[\\.!\\?]")

public class PirateSpeakCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Converts some text into Pirate speak",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text
    private let substitutions: [String: String]
    private let interjections: [String]

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
        "\\bocean\\b": "briney deep",
        "\\beggs\\b": "cackle fruit",
        "\\bdaredevil\\b": "swashbuckler",
        "\\btreasure\\b": "booty",
        "\\breward\\b": "bounty",
        "\\chest\\b": "coffer",
        "ng\\b": "n'",
        "ngs\\b": "n's",
        "st\\b": "s'",
        "you": "ye",
        "\\bto": "t'",
        "\\bis": "be"
    ], interjections: [String] = [
        "Arr!",
        "C'mere, me beauty.",
        "Savvy?",
        "Shiver me timbers!",
        "Sink me!",
        "Yo ho ho."
    ]) {
        self.substitutions = substitutions
        self.interjections = interjections
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter some text!")
            return
        }

        let preprocessed = punctuationPattern.replace(in: input) { "\($0[0])\(interjections.randomElement().filter { _ in Int.random(in: 0..<4) < 3 }.map { " \($0)" } ?? "")" }
        let result = substitutions.reduce(preprocessed) { try! Regex(from: $1.key, caseSensitive: false).replace(in: $0, with: $1.value, casePreserving: true) }
        output.append(result)
    }
}
