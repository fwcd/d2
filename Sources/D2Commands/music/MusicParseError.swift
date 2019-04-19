enum MusicParseError: Error {
	case invalidChord(String)
	case invalidRootNote(String)
}
