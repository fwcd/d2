enum TicTacToeError: Error {
	case invalidMove(TicTacToeRole, Int, Int)
	case outOfBounds(Int, Int)
}
