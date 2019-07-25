import D2Utils

public enum TicTacToeRole: String, CaseIterable, RichValueConvertible {
	case x = "x"
	case o = "o"
	case empty = " "
	
	static var allPlayerCases: [TicTacToeRole] { return allCases.filter { $0.isPlayerRole } }
	
	public var asRichValue: RichValue {
		switch self {
			case .x: return .text(":x:")
			case .o: return .text(":o:")
			case .empty: return .text(":white_large_square:")
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
