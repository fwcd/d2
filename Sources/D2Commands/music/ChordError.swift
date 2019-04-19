enum ChordError: Error {
	case invalidChord(String)
	case invalidRootNote(String)
	case notOnGuitarFretboard(Chord)
}
