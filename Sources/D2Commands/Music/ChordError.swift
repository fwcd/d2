import MusicTheory

enum ChordError: Error {
    case invalidChord(String)
    case invalidRootNote(String)
    case notOnFretboard(Chord)
}
