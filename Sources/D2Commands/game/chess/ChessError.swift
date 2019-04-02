public enum ChessError: Error {
	case ambiguousMove(String, ChessMove)
	case invalidMove(String, ChessMove)
	case incompleteMove(String, ChessMove)
	case moveOutOfBounds(String, ChessMove)
}
