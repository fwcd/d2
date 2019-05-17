public enum D2ScriptError: Error {
	case numberFormatError(String)
	case unrecognizedToken(String)
	case syntaxError(String)
}
