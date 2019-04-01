import D2Graphics
import D2Utils

public enum UnoColor: String, Hashable, CaseIterable, DiscordStringEncodable {
	case yellow = "yellow"
	case red = "red"
	case green = "green"
	case blue = "blue"
	
	public var color: Color {
		switch self {
			case .yellow: return Colors.yellow
			case .red: return Colors.red
			case .green: return Colors.green
			case .blue: return Colors.blue
		}
	}
	
	public var discordStringEncoded: String {
		switch self {
			case .yellow: return ":large_orange_diamond:"
			case .red: return ":red_circle:"
			case .green: return ":green_book:"
			case .blue: return ":large_blue_diamond:"
		}
	}
}
