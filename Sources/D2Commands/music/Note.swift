import Utils

fileprivate struct NoteBlueprint: Hashable {
    let letter: NoteLetter
    let accidental: Accidental
}

/// Maps semitones to unoctaved notes on the common twelve-tone scale.
/// Corresponds to the individual keys to on the piano.
fileprivate let twelveToneOctaveBlueprints: [[NoteBlueprint]] = [
    [NoteBlueprint(letter: .c, accidental: .none)],
    [NoteBlueprint(letter: .c, accidental: .sharp), NoteBlueprint(letter: .d, accidental: .flat)],
    [NoteBlueprint(letter: .d, accidental: .none)],
    [NoteBlueprint(letter: .d, accidental: .sharp), NoteBlueprint(letter: .e, accidental: .flat)],
    [NoteBlueprint(letter: .e, accidental: .none)],
    [NoteBlueprint(letter: .f, accidental: .none)],
    [NoteBlueprint(letter: .f, accidental: .sharp), NoteBlueprint(letter: .g, accidental: .flat)],
    [NoteBlueprint(letter: .g, accidental: .none)],
    [NoteBlueprint(letter: .g, accidental: .sharp), NoteBlueprint(letter: .a, accidental: .flat)],
    [NoteBlueprint(letter: .a, accidental: .none)],
    [NoteBlueprint(letter: .a, accidental: .sharp), NoteBlueprint(letter: .b, accidental: .flat)],
    [NoteBlueprint(letter: .b, accidental: .none)]
]

let twelveToneOctave: [Note] = twelveToneOctaveBlueprints.enumerated().flatMap { (i, bs) in bs.map { Note(blueprint: $0, semitone: i) } }

/**
 * Matches a single musical note.
 *
 * 1. group: letter
 * 2. group: accidental (optional)
 * 3. group: octave (optional)
 */
fileprivate let notePattern = try! Regex(from: "([a-zA-Z])([b#]?)(\\d+)?")

struct Note: Hashable, Comparable, Strideable, CustomStringConvertible {
    let letter: NoteLetter
    let octave: Int? // The octave in scientific pitch notation
    let accidental: Accidental
    let semitone: Int // Semitones in an octave

    var numValue: Int { ((octave ?? 0) * twelveToneOctaveBlueprints.count) + semitone }
    var description: String { return "\("\(letter)".uppercased())\(accidental.rawValue)\(octave.map { String($0) } ?? "")" }

    var withoutOctave: Note { Note(letter: letter, accidental: accidental, semitone: semitone) }

    init(letter: NoteLetter, accidental: Accidental, semitone: Int, octave: Int? = nil) {
        self.letter = letter
        self.octave = octave
        self.accidental = accidental
        self.semitone = semitone %% twelveToneOctaveBlueprints.count
    }

    fileprivate init(blueprint: NoteBlueprint, semitone: Int, octave: Int? = nil)  {
        self.init(letter: blueprint.letter, accidental: blueprint.accidental, semitone: semitone, octave: octave)
    }

    init(numValue: Int) {
        guard let note = Self.enharmonicEquivalents(numValue: numValue).first else { fatalError("No enharmonic equivalent found") }
        self.init(letter: note.letter, accidental: note.accidental, semitone: note.semitone, octave: note.octave)
    }

    init(of str: String) throws {
        guard let parsed = notePattern.firstGroups(in: str) else { throw NoteError.invalidNote(str) }
        guard let letter = NoteLetter.of(parsed[1]) else { throw NoteError.invalidNoteLetter(parsed[1]) }
        let accidental = Accidental(rawValue: parsed[2]) ?? .none
        let octave = parsed[3].nilIfEmpty.flatMap { Int($0) }
        guard let (semitone, _) = twelveToneOctaveBlueprints.enumerated().first(where: { $0.1.contains(NoteBlueprint(letter: letter, accidental: accidental)) }) else { throw NoteError.notInTwelveToneOctave(str) }

        self.init(letter: letter, accidental: accidental, semitone: semitone, octave: octave)
    }

    static func enharmonicEquivalents(numValue: Int) -> [Note] {
        assert(numValue >= 0) // TODO: Investigate supporting negative numValues by using floor/clock modulo and division

        let enharmonics = twelveToneOctaveBlueprints[numValue %% twelveToneOctaveBlueprints.count]

        return enharmonics.map { Note(
            letter: $0.letter,
            accidental: $0.accidental,
            semitone: numValue % twelveToneOctaveBlueprints.count,
            octave: numValue / twelveToneOctaveBlueprints.count
        ) }
    }

    static func +(lhs: Note, rhs: NoteInterval) -> Note {
        let octavesDelta: Int

        if rhs.degrees >= 0 {
            octavesDelta = rhs.degrees / 7
        } else {
            octavesDelta = (rhs.degrees - 6) / 7
        }

        let nextSemitone = (lhs.semitone + rhs.semitones) %% twelveToneOctaveBlueprints.count
        let nextLetter = lhs.letter + rhs.degrees
        let candidates = twelveToneOctaveBlueprints[nextSemitone]
        guard let twelveToneNote = candidates.first(where: { $0.letter == nextLetter }) ?? candidates.first else {
            fatalError("Could not locate note with semitone \(nextSemitone) and letter \(nextLetter) in twelve-tone octave (from: \(lhs) with interval: \(rhs))")
        }

        return Note(letter: nextLetter, accidental: twelveToneNote.accidental, semitone: nextSemitone, octave: lhs.octave.map { $0 + octavesDelta })
    }

    static func -(lhs: Note, rhs: NoteInterval) -> Note {
        return lhs + (-rhs)
    }

    func matches(_ rhs: Note) -> Bool {
        return (semitone == rhs.semitone)
            && (octave == nil || rhs.octave == nil || octave == rhs.octave)
    }

    func advanced(by n: Int) -> Note {
        Note(numValue: numValue + n)
    }

    func distance(to n: Note) -> Int {
        n.numValue - numValue
    }
}
