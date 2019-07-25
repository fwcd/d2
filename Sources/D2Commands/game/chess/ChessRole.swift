import D2Utils

public enum ChessRole: String, Hashable, CaseIterable, Codable, RichValueConvertible {
	case white
	case black
	
	public var asRichValue: RichValue {
		switch self {
			case .white: return .text(":white_circle:")
			case .black: return .text(":black_circle:")
		}
	}
	
	var opponent: ChessRole {
		switch self {
			case .white: return .black
			case .black: return .white
		}
	}
}
