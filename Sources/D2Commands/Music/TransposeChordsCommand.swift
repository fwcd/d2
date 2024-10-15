import Utils

public class TransposeChordsCommand: RegexCommand {
    public let info = CommandInfo(
        category: .music,
        shortDescription: "Transposes a sequence of notes/chords",
        helpText: "Syntax: [number of half steps] [note]...",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public let outputValueType: RichValueType = .text
    public let inputPattern = #/(?<halfSteps>-?\d+)\s+(?<notes>.+)/#

    public init() {}

    public func invoke(with input: Input, output: any CommandOutput, context: CommandContext) async {
        guard
            let halfSteps = Int(input.halfSteps),
            let chords = try? input.notes.split(separator: " ").map({ try CommonChord(of: String($0)) }) else {
            await output.append(errorText: info.helpText!)
            return
        }

        await output.append(chords.compactMap { $0.advanced(by: halfSteps) }.map(String.init(describing:)).joined(separator: " "))
    }
}
