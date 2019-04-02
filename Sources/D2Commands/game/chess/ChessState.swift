import SwiftDiscord
import D2Utils
import D2Permissions

public struct ChessState: GameState {
	public typealias Role = ChessRole
	public typealias Board = ChessBoard
	public typealias Move = ChessMove
	
	private let whitePlayer: GamePlayer
	private let blackPlayer: GamePlayer
	public private(set) var board: Board
	public private(set) var currentRole: Role = .white
	public private(set) var moveCount = 0
	public var playersDescription: String { return "`\(whitePlayer.username)` as :white_circle: vs. `\(blackPlayer.username)` as :black_circle:" }
	
	public var possibleMoves: Set<Move> {
		return Set(board.model.positions
			.filter { board.model[$0]?.color == currentRole }
			.flatMap { findPossibleMoves(at: $0) })
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
	
	private func findPossibleMoves(at position: Vec2<Int>) -> Set<Move> {
		guard let piece = board.model[position] else { return [] }
		let pieceTypeBoard = board.model.pieceTypes
		let unfilteredMoves: [Move] = piece.piece.possibleMoves(from: position, board: pieceTypeBoard, role: currentRole, moved: piece.moved)
		
		for move in unfilteredMoves {
			guard move.pieceType != nil else { fatalError("ChessPiece returned move without 'pieceType' (invalid according to the contract)") }
			guard move.color != nil else { fatalError("ChessPiece returned move without 'color' (invalid according to the contract)") }
			guard move.origin != nil else { fatalError("ChessPiece returned move without 'origin' (invalid according to the contract)") }
			guard move.destination != nil else { fatalError("ChessPiece returned move without 'destination' (invalid according to the contract)") }
		}
		
		let moves: [Move] = unfilteredMoves
			.filter { pieceTypeBoard.isInBounds($0.destination!) }
			.compactMap {
				let destinationPiece = board.model[$0.destination!]
				if destinationPiece?.color == currentRole {
					return nil
				} else {
					var move = $0
					move.isCapture = destinationPiece?.color == currentRole.opponent
					return move
				}
			}
		
		return Set(moves)
	}
	
	public mutating func perform(move unresolvedMove: Move) throws {
		let resolvedMove = try unambiguouslyResolve(move: unresolvedMove)
		
		try board.model.perform(move: resolvedMove)
		currentRole = currentRole.opponent
		moveCount += 1
	}
	
	func resolve(move: Move) -> [Move] {
		return possibleMoves
			.filter { $0.matches(move) }
	}
	
	func unambiguouslyResolve(move unresolvedMove: Move) throws -> Move {
		let resolvedMoves = resolve(move: unresolvedMove)
		guard resolvedMoves.count != 0 else { throw GameError.invalidMove("Move is not allowed: `\(unresolvedMove)`") }
		guard resolvedMoves.count == 1 else { throw GameError.ambiguousMove("Move is ambiguous: `\(unresolvedMove)`") }
		return resolvedMoves.first!
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
