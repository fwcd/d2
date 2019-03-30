import Foundation
import SwiftDiscord

public struct TicTacToeState: GameState, CustomStringConvertible {
	public typealias Role = TicTacToeRole
	public typealias Board = TicTacToeBoard
	public typealias Move = TicTacToeMove
	
	private let playerX: GamePlayer
	private let playerO: GamePlayer
	public private(set) var board = Board()
	public private(set) var currentRole: Role = .x
	public var description: String { return "`\(playerX.username)` as :x: vs. `\(playerO.username)` as :o:" }
	
	public init(firstPlayer: GamePlayer, secondPlayer: GamePlayer) {
		playerX = firstPlayer
		playerO = secondPlayer
	}
	
	public mutating func perform(move: Move) throws {
		try performMoveAt(row: move.row, col: move.column)
	}
	
	private mutating func performMoveAt(row: Int, col: Int) throws {
		let next = try board.with(currentRole, atRow: row, col: col)
		board = next
		currentRole = currentRole.opponent
	}
	
	public func playerOf(role: Role) -> GamePlayer? {
		switch role {
			case .x: return playerX
			case .o: return playerO
			default: return nil
		}
	}
	
	public func rolesOf(player: GamePlayer) -> [Role] {
		var roles = [Role]()
		
		if playerX == player { roles.append(.x) }
		if playerO == player { roles.append(.o) }
		
		return roles
	}
}
