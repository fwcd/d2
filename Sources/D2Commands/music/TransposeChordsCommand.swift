import D2Utils

fileprivate let argsPattern = try! Regex(from: "(-?\\d+)\\s+(.+)")

public class TransposeChordsCommand: StringCommand {
    public let info = CommandInfo(
        category: .music,
        shortDescription: "Transposes a sequence of notes/chords",
        helpText: "Syntax: [number of half steps] [note]...",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard
            let parsedArgs = argsPattern.firstGroups(in: input),
            let halfSteps = Int(parsedArgs[1]),
            let chords = try? parsedArgs[2].split(separator: " ").map({ try CommonChord(of: String($0)) }) else {
            output.append(errorText: info.helpText!)
            return
        }

        output.append(chords.compactMap { $0.advanced(by: halfSteps) }.map(String.init(describing:)).joined(separator: " "))
    }
}
