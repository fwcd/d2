import SwiftDiscord
import D2Permissions

public struct UnoState: GameState, CustomStringConvertible {
	public typealias Role = Int
	public typealias Board = UnoBoard
	public typealias Move = UnoMove
	
	private let players: [GamePlayer]
	public private(set) var board = Board()
	public private(set) var currentRole: Role = 0
	public var description: String { return players.map { "`\($0.username)`" }.joined(separator: " vs. ") }
	
	public var possibleMoves: Set<Move> {
		return hands[currentRole]!.map { Move(playing: $0) }
	}
	
	public init(players: [GamePlayer]) {
		self.players = players
	}
	
	public init(firstPlayer: GamePlayer, secondPlayer: GamePlayer) {
		players = [firstPlayer, secondPlayer]
	}
	
	public mutating func perform(move: Move) throws {
		// TODO
	}
	
	public func playerOf(role: Role) -> GamePlayer? {
		return players[safely: role]
	}
	
	public func rolesOf(player: GamePlayer) -> [Role] {
		return players.allIndices(of: player)
	}
}
