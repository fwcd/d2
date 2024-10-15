import Utils
import MusicTheory

/// Matches a single musical note.
nonisolated(unsafe) private let notePattern = #/(?<letter>[a-zA-Z])(?<accidental>[b#]?)(?<octave>\d+)?/#

extension Note {
    // TODO: Move this method upstream

    /// Parses a note from the given string.
    init(parsing str: String) throws {
        guard let parsed = try? notePattern.firstMatch(in: str) else { throw NoteError.invalidNote(str) }
        guard let letter = NoteLetter(parsing: String(parsed.letter)) else { throw NoteError.invalidNoteLetter(String(parsed.letter)) }
        let accidental = NoteAccidental(String(parsed.accidental)) ?? .unaltered
        let noteClass = NoteClass(letter: letter, accidental: accidental)
        let octave = parsed.octave.flatMap { Int($0) } ?? 0

        self.init(noteClass: noteClass, octave: octave)
    }
}
