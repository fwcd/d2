public enum GameError: Error {
	case missing(String, String)
	case invalid(String, String)
	case invalidMove(String)
	case ambiguousMove(String)
	case incompleteMove(String)
	case moveOutOfBounds(String)
}
