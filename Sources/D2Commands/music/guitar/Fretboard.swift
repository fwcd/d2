import MusicTheory

let standardGuitarTuning = ["E2", "A2", "D3", "G3", "B3", "E4"].map { try! Note(parsing: $0) }
let standardUkuleleTuning = ["G4", "C4", "E4", "A4"].map { try! Note(parsing: $0) }
let standardBassTuning = ["E1", "A1", "D2", "G2"].map { try! Note(parsing: $0) }

struct Fretboard {
    private let strings: [[Note]]
    var stringCount: Int { return strings.count }

    init(fretCount: Int = 12, tuning: [Note] = standardGuitarTuning) {
        strings = tuning.map {
            var fret = [Note]()
            var note = $0

            for _ in 0..<fretCount {
                fret.append(note)
                note = note + .minorSecond
            }

            return fret
        }
    }

    struct Location {
        let guitarString: Int // The string index is zero-indexed
        let fret: Int // The fret is zero-indexed
    }

    struct NoteResult {
        let note: Note
        let location: Location
    }

    func find(note: Note, on guitarString: Int) -> NoteResult? {
        return strings[safely: guitarString]?
            .enumerated()
            .map { NoteResult(note: $0.1, location: Location(guitarString: guitarString, fret: $0.0)) }
            .first { note.noteClass == $0.note.noteClass }
    }

    func find(note: Note) -> NoteResult? {
        return (0..<strings.count).compactMap { find(note: note, on: $0) }.first
    }
}
