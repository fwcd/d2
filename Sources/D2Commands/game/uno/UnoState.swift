import SwiftDiscord
import D2Permissions

public struct UnoState: GameState, CustomStringConvertible {
	public typealias Role = Int
	public typealias Board = UnoBoard
	public typealias Move = UnoMove
	public typealias Hand = UnoHand
	
	private let players: [GamePlayer]
	public private(set) var board = Board()
	public private(set) var currentRole: Role = 0
	public var hands: [Role: Hand]
	public var description: String { return players.map { "`\($0.username)`" }.joined(separator: " vs. ") }
	
	public var possibleMoves: Set<Move> { return Set(hands[currentRole]?.cards.map { Move(playing: ) } ?? [])
	
	public var winner: Role? {}
	public var isDraw: Bool {}
	
	public init(players: [GamePlayer]) {
		self.players = players
		hands = Dictionary(uniqueKeysWithValues: Array(repeating: UnoHand(), count: players.count).enumerated())
	}
	
	public init(firstPlayer: GamePlayer, secondPlayer: GamePlayer) {
		self.init([firstPlayer, secondPlayer])
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
