enum MapQuestError: Error {
	case urlError(String)
	case httpError(Error?)
	case jsonIOError(Error)
	case jsonParseError(Any, String)
	case foundNoMatches(String)
}
