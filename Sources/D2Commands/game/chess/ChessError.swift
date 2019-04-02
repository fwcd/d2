public enum ChessError: Error {
	case incompleteMove(String, ChessMove)
	case moveOutOfBounds(String, ChessMove)
}
