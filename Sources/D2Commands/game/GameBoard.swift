import D2Utils

public protocol GameBoard: DiscordEncodable {
	associatedtype Role: DiscordEncodable & Hashable
	
	var winner: Role? { get }
	var isDraw: Bool { get }
}
