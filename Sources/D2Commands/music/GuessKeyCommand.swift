import D2Utils

public class GuessKeyCommand: StringCommand {
    public let info = CommandInfo(
        category: .music,
        shortDescription: "Guesses a key from a list of possible",
        helpText: "Syntax: [note]...",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty, let notes = (try? input.split(separator: " ").map({ try Note(of: String($0)) })).map(Set.init) else {
            output.append(errorText: info.helpText!)
            return
        }

        let scales = twelveToneOctave
            .flatMap { key -> [Scale] in [DiatonicMajorScale(key: key), DiatonicMinorScale(key: key)] }
            .filter { notes.isSubset(of: $0.notes) }
        output.append("Possible keys: \(scales.map(String.init(describing:)).joined(separator: " "))")
    }
}
