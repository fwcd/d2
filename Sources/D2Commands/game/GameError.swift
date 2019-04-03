public enum GameError: Error {
	case invalidMove(String)
	case ambiguousMove(String)
	case incompleteMove(String)
	case moveOutOfBounds(String)
}
