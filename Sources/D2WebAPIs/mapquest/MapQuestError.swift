public enum MapQuestError: Error {
	case missingApiKey(String)
	case urlError(String)
	case httpError(Error?)
	case jsonIOError(Error)
	case jsonParseError(Any, String)
	case foundNoMatches(String)
}
