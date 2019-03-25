enum TicTacToeRole: String {
	case x = "x"
	case o = "o"
	case empty = " "
	
	var discordEncoded: String {
		switch self {
			case .x: return ":x:"
			case .o: return ":o:"
			case .empty: return ":white_large_square:"
		}
	}
}
