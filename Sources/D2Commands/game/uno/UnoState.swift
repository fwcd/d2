import D2MessageIO
import D2Permissions

public struct UnoState: GameState, Multiplayer {
	public typealias Role = Int
	public typealias Board = UnoBoard
	public typealias Move = UnoMove
	public typealias Hand = UnoHand
	
	public let players: [GamePlayer]
	private var advanceForward: Bool = true
	public private(set) var board: Board
	public private(set) var currentRole: Role = 0
	public var hands: [Role: Hand]
	public var handsDescription: String? { return hands.map { "`\(playerOf(role: $0.key)?.username ?? "?")`: \($0.value.cards.count)" }.joined(separator: ",") }
	
	public var possibleMoves: Set<Move> {
		var moves = hands[currentRole]?.cards
			.filter { card in board.lastDiscarded.map { board.topColor == card.color || card.canBePlaced(onTopOf: $0) } ?? true }
			.flatMap { card in
				return card.canPickColor
					? UnoColor.allCases.map { Move(playing: card, pickingColor: $0) }
					: [Move(playing: card)]
			}
			?? [Move]()
		
		if !board.deck.isEmpty {
			moves = moves + [Move(drawingCard: true)]
		}
		
		return Set(moves)
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
	
	public mutating func perform(move: Move, by role: Role) throws {
		var nextHand = hands[currentRole]!
		var opponentDrawCardCount = 0
		var skipDistance = 0
		
		if let card = move.card {
			board.push(card: card)
			nextHand.cards.removeFirst(value: card)
			
			opponentDrawCardCount = card.drawCardCount
			skipDistance = card.skipDistance
			
			if case .action(.reverse, _) = card {
				advanceForward = !advanceForward
			}
		}
		
		if move.drawsCard {
			guard let drawnCard = board.deck.drawRandomCard() else { throw GameError.invalidMove("Encountered empty deck while drawing card") }
			nextHand.cards.append(drawnCard)

			if board.deck.isEmpty {
				board.deck.refill()
			}
		}
		
		if let nextColor = move.nextColor {
			board.topColor = nextColor
		}
		
		hands[currentRole] = nextHand
		currentRole = (currentRole + ((1 + skipDistance) * (advanceForward ? 1 : -1))).clockModulo(players.count)
		
		hands[currentRole]!.cards.append(contentsOf: board.deck.drawRandomCards(count: opponentDrawCardCount))
	}
}
