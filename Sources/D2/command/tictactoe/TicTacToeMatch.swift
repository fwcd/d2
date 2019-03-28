import Foundation
import SwiftDiscord

final class TicTacToeMatch: GameMatch, CustomStringConvertible {
	private let startTime: Date
	private let playerX: DiscordUser
	private let playerO: DiscordUser
	private(set) var board: TicTacToeBoard
	private(set) var currentRole: TicTacToeRole = .x
	var description: String { return "`\(playerX.username)` as :x: vs. `\(playerO.username)` as :o:" }
	
	typealias Role = TicTacToeRole
	typealias Board = TicTacToeBoard
	typealias Move = TicTacToeMove
	
	var elapsedTime: TimeInterval {
		return -startTime.timeIntervalSinceNow
	}
	
	init(firstPlayer: DiscordUser, secondPlayer: DiscordUser) {
		playerX = firstPlayer
		playerO = secondPlayer
		startTime = Date()
		board = TicTacToeBoard()
	}
	
	func perform(moveBy role: TicTacToeRole, atRow row: Int, col: Int) throws {
		let next = try board.with(role, atRow: row, col: col)
		board = next
		currentRole = currentRole.opponent
	}
	
	func playerOf(role: TicTacToeRole) -> DiscordUser? {
		switch role {
			case .x: return playerX
			case .o: return playerO
			default: return nil
		}
	}
	
	func rolesOf(player: DiscordUser) -> [TicTacToeRole] {
		var roles = [TicTacToeRole]()
		
		if playerX.id == player.id { roles.append(.x) }
		if playerO.id == player.id { roles.append(.o) }
		
		return roles
	}
}
