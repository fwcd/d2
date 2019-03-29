import Foundation
import SwiftDiscord

struct TicTacToeState: GameState, CustomStringConvertible {
	typealias Role = TicTacToeRole
	typealias Board = TicTacToeBoard
	typealias Move = TicTacToeMove
	
	private let playerX: DiscordUser
	private let playerO: DiscordUser
	private(set) var board = Board()
	private(set) var currentRole: Role = .x
	var description: String { return "`\(playerX.username)` as :x: vs. `\(playerO.username)` as :o:" }
	
	init(firstPlayer: DiscordUser, secondPlayer: DiscordUser) {
		playerX = firstPlayer
		playerO = secondPlayer
	}
	
	mutating func perform(move: Move) throws {
		try performMoveAt(row: move.row, col: move.column)
	}
	
	private mutating func performMoveAt(row: Int, col: Int) throws {
		let next = try board.with(currentRole, atRow: row, col: col)
		board = next
		currentRole = currentRole.opponent
	}
	
	func playerOf(role: Role) -> DiscordUser? {
		switch role {
			case .x: return playerX
			case .o: return playerO
			default: return nil
		}
	}
	
	func rolesOf(player: DiscordUser) -> [Role] {
		var roles = [Role]()
		
		if playerX.id == player.id { roles.append(.x) }
		if playerO.id == player.id { roles.append(.o) }
		
		return roles
	}
}
