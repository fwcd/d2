import SwiftDiscord
import D2Utils
import D2Permissions

public struct ChessState: GameState, CustomStringConvertible {
	public typealias Role = ChessRole
	public typealias Board = ChessBoard
	public typealias Move = ChessMove
	
	private let whitePlayer: GamePlayer
	private let blackPlayer: GamePlayer
	public private(set) var board: Board
	public private(set) var currentRole: Role = .white
	public private(set) var moveCount = 0
	public var description: String { return "`\(whitePlayer.username)` as :white_circle: vs. `\(blackPlayer.username)` as :black_circle:" }
	
	public var possibleMoves: Set<Move> {
		let pieceTypeBoard = board.pieceTypes
		let firstMove = moveCount == 0
		let boardPositions = (0..<board.ranks).flatMap { y in (0..<board.files).map { Vec2(x: $0, y: y) } }
		let currentPieces: [(Vec2<Int>, ColoredPiece)] = boardPositions
			.map { ($0, board[$0]) }
			.filter { $0.1 != nil }
			.map { ($0.0, $0.1!) }
		let moves = currentPieces
			.filter { $0.1.color == currentRole }
			.flatMap { $0.1.piece.possibleMoves(from: $0.0, board: pieceTypeBoard, role: currentRole, firstMove: firstMove) }
		
		return Set(moves)
	}
	
	public var winner: Role? { return nil /* TODO */ }
	public var isDraw: Bool { return false /* TODO */ }
	
	init(firstPlayer whitePlayer: GamePlayer, secondPlayer blackPlayer: GamePlayer, board: Board) {
		self.whitePlayer = whitePlayer
		self.blackPlayer = blackPlayer
		self.board = board
	}
	
	public init(firstPlayer whitePlayer: GamePlayer, secondPlayer blackPlayer: GamePlayer) {
		self.init(firstPlayer: whitePlayer, secondPlayer: blackPlayer, board: Board())
	}
	
	public mutating func perform(move unresolvedMove: Move) throws {
		let resolvedMoves = resolve(move: unresolvedMove)
		guard resolvedMoves.count != 0 else { throw ChessError.invalidMove("Move is not allowed", unresolvedMove) }
		guard resolvedMoves.count == 1 else { throw ChessError.ambiguousMove("Move is ambiguous", unresolvedMove) }
		let resolvedMove = resolvedMoves.first!
		
		try board.perform(move: resolvedMove)
		moveCount += 1
	}
	
	private func resolve(move: Move) -> [Move] {
		return possibleMoves
			.filter { $0.matches(move) }
	}
	
	public func playerOf(role: Role) -> GamePlayer? {
		switch role {
			case .white: return whitePlayer
			case .black: return blackPlayer
		}
	}
	
	public func rolesOf(player: GamePlayer) -> [Role] {
		var roles = [Role]()
		
		if player == whitePlayer { roles.append(.white) }
		if player == blackPlayer { roles.append(.black) }
		
		return roles
	}
}
