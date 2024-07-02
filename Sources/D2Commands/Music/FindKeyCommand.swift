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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty,
              let notes = try? input.split(separator: " ").map({ try Note(parsing: String($0)) }) else {
            await output.append(errorText: info.helpText!)
            return
        }

        let noteClasses = Set(notes.map(\.noteClass))
        let scales = NoteClass.twelveToneOctave
            .flatMap { key -> [any Scale & AbbreviatedClassName] in [
                MajorScale(key: Note(noteClass: key, octave: 0)),
                MinorScale(key: Note(noteClass: key, octave: 0)),
            ] }
            .filter { noteClasses.isSubset(of: $0.notes.map(\.noteClass)) }
        await output.append("Possible keys: \(scales.map(\.abbreviatedClassName).joined(separator: " "))")
    }
}
