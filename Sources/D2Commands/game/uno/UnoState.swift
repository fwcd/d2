import SwiftDiscord
import D2Permissions

public struct UnoState: GameState, CustomStringConvertible {
	public typealias Role = Int
	public typealias Board = UnoBoard
	public typealias Move = UnoMove
	public typealias Hand = UnoHand
	
	private let players: [GamePlayer]
	public private(set) var board: Board
	public private(set) var currentRole: Role = 0
	public var hands: [Role: Hand]
	public var description: String { return players.map { "`\($0.username)`" }.joined(separator: " vs. ") }
	
	public var possibleMoves: Set<Move> {
		let moves = hands[currentRole]?.cards
			.filter { card in board.lastDiscarded.map { card.canBePlaced(onTopOf: $0) } ?? true }
			.map { Move(playing: $0) }
			?? []
		
		if board.deck.isEmpty {
			return Set(moves)
		} else {
			return Set(moves + [Move(drawingCard: true)])
		}
	}
	
	public var winner: Role? { return hands.first { $0.1.isEmpty }?.0 }
	public var isDraw: Bool { return hands.allSatisfy { $0.1.isEmpty } }
	
	public init(players: [GamePlayer]) {
		self.players = players
		board = Board()
		hands = [:]
		
		for i in 0..<players.count {
			hands[i] = Hand(cards: board.deck.drawRandomCards(count: 7))
		}
	}
	
	public init(firstPlayer: GamePlayer, secondPlayer: GamePlayer) {
		self.init(players: [firstPlayer, secondPlayer])
	}
	
	public mutating func perform(move: Move) throws {
		var nextHand = hands[currentRole]!
		
		if let card = move.card {
			board.push(card: card)
			nextHand.cards.removeFirst(value: card)
		}
		
		if move.drawsCard {
			guard !board.deck.isEmpty else { throw GameError.invalidMove("Encountered empty deck while drawing card") }
			nextHand.cards.append(board.deck.drawRandomCard()!)
		}
		
		hands[currentRole] = nextHand
		currentRole = (currentRole + 1) % players.count
	}
	
	public func playerOf(role: Role) -> GamePlayer? {
		return players[safely: role]
	}
	
	public func rolesOf(player: GamePlayer) -> [Role] {
		return players.allIndices(of: player)
	}
}
