import Utils
import MusicTheory

/// Matches a single musical note.
///
/// 1. group: letter
/// 2. group: accidental (optional)
/// 3. group: octave (optional)
fileprivate let notePattern = try! LegacyRegex(from: "([a-zA-Z])([b#]?)(\\d+)?")

extension Note {
    // TODO: Move this method upstream

    /// Parses a note from the given string.
    init(parsing str: String) throws {
        guard let parsed = notePattern.firstGroups(in: str) else { throw NoteError.invalidNote(str) }
        guard let letter = NoteLetter(parsing: parsed[1]) else { throw NoteError.invalidNoteLetter(parsed[1]) }
        let accidental = NoteAccidental(parsed[2]) ?? .unaltered
        let noteClass = NoteClass(letter: letter, accidental: accidental)
        let octave = parsed[3].nilIfEmpty.flatMap { Int($0) } ?? 0

        self.init(noteClass: noteClass, octave: octave)
    }
}
