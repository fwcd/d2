enum NoteError: Error {
	case invalidNote(String)
	case notInTwelveToneOctave(String)
	case invalidNoteLetter(String)
}
