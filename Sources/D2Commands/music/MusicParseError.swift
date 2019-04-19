enum MusicParseError: Error {
	case invalidChord(String)
	case invalidRootNote(String)
	case invalidNote(String)
	case notInTwelveToneOctave(String)
	case invalidNoteLetter(String)
}
