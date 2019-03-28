import D2Utils

protocol GameBoard: DiscordEncodable {
	associatedtype Role: DiscordEncodable & Equatable
	
	var winner: Role? { get }
	var isDraw: Bool { get }
}
