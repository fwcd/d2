import D2Utils

protocol GameBoard: DiscordEncodable {
	associatedtype Role: DiscordEncodable & Hashable
	
	var winner: Role? { get }
	var isDraw: Bool { get }
}
