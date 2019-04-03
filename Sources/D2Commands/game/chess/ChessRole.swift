import D2Utils

public enum ChessRole: String, Hashable, CaseIterable, DiscordStringEncodable {
	case white
	case black
	
	public var discordStringEncoded: String {
		switch self {
			case .white: return ":white_circle:"
			case .black: return ":black_circle:"
		}
	}
	
	var opponent: ChessRole {
		switch self {
			case .white: return .black
			case .black: return .white
		}
	}
}
