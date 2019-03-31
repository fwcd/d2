import D2Utils

public enum TicTacToeRole: String, CaseIterable, DiscordStringEncodable {
	case x = "x"
	case o = "o"
	case empty = " "
	
	static var allPlayerCases: [TicTacToeRole] { return allCases.filter { $0.isPlayerRole } }
	
	public var discordStringEncoded: String {
		switch self {
			case .x: return ":x:"
			case .o: return ":o:"
			case .empty: return ":white_large_square:"
		}
	}
	
	var isPlayerRole: Bool { return self != .empty }
	var opponent: TicTacToeRole {
		switch self {
			case .x: return .o
			case .o: return .x
			default: return self
		}
	}
}
