import Utils

fileprivate let argsPattern = #/(?<halfSteps>-?\d+)\s+(?<notes>.+)/#

public class TransposeChordsCommand: StringCommand {
    public let info = CommandInfo(
        category: .music,
        shortDescription: "Transposes a sequence of notes/chords",
        helpText: "Syntax: [number of half steps] [note]...",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard
            let parsedArgs = try? argsPattern.firstMatch(in: input),
            let halfSteps = Int(parsedArgs.halfSteps),
            let chords = try? parsedArgs.notes.split(separator: " ").map({ try CommonChord(of: String($0)) }) else {
            await output.append(errorText: info.helpText!)
            return
        }

        await output.append(chords.compactMap { $0.advanced(by: halfSteps) }.map(String.init(describing:)).joined(separator: " "))
    }
}
