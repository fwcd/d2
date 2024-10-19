import Utils

nonisolated(unsafe) private let punctuationPattern = #/[\.!\?]/#

nonisolated(unsafe) private let substitutions = [
    (#/hello/#, "ahoy"),
    (#/yes/#, "aye"),
    (#/this/#, "'tis"),
    (#/the/#, "th'"),
    (#/my/#, "me"),
    (#/and/#, "'n"),
    (#/as/#, "'s"),
    (#/of/#, "o'"),
    (#/\bthose\b/#, "'ose"),
    (#/\bwhoa\b/#, "avast"),
    (#/\bvery\b/#, "mighty"),
    (#/\bocean\b/#, "briney deep"),
    (#/\beggs\b/#, "cackle fruit"),
    (#/\bdaredevil\b/#, "swashbuckler"),
    (#/\btreasure\b/#, "booty"),
    (#/\breward\b/#, "bounty"),
    (#/chest\b/#, "coffer"),
    (#/ng\b/#, "n'"),
    (#/ngs\b/#, "n's"),
    (#/st\b/#, "s'"),
    (#/you/#, "ye"),
    (#/\bto/#, "t'"),
    (#/\bis/#, "be"),
].map { (pattern: $0.0.ignoresCase(), substitution: $0.1) }

fileprivate let interjections = [
    "Arr!",
    "C'mere, me beauty.",
    "Savvy?",
    "Shiver me timbers!",
    "Sink me!",
    "Yo ho ho.",
]

public class PirateSpeakCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Converts some text into Pirate speak",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter some text!")
            return
        }

        let preprocessed = input.replacing(punctuationPattern) { "\($0.0)\(interjections.randomElement().filter { _ in Int.random(in: 0..<4) < 3 }.map { " \($0)" } ?? "")" }
        let result = substitutions.reduce(preprocessed) { $0.replacing($1.pattern, with: $1.substitution) }
        await output.append(result)
    }
}
