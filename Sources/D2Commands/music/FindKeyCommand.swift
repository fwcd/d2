import Utils
import MusicTheory

public class FindKeyCommand: StringCommand {
    public let info = CommandInfo(
        category: .music,
        shortDescription: "Determines a list of possible major/minor keys given a list of notes",
        helpText: "Syntax: [note]...",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard !input.isEmpty, let notes = (try? input.split(separator: " ").map({ try Note(parsing: String($0)) })).map(Set.init) else {
            output.append(errorText: info.helpText!)
            return
        }

        let scales = NoteClass.twelveToneOctave
            .flatMap { key -> [Scale] in [
                MajorScale(key: Note(noteClass: key)),
                MinorScale(key: Note(noteClass: key)),
            ] }
            .filter { notes.isSubset(of: $0.notes) }
        output.append("Possible keys: \(scales.map(String.init(describing:)).joined(separator: " "))")
    }
}
