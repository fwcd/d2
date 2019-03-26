import Foundation
import SwiftDiscord

class TicTacToeMatch {
	private let startTime: Date
	private let playerX: DiscordUser
	private let playerO: DiscordUser
	private(set) var board: TicTacToeBoard
	private(set) var currentPlayer: TicTacToeRole = .x
	
	var elapsedTime: TimeInterval {
		return -startTime.timeIntervalSinceNow
	}
	
	init(playerX: DiscordUser, playerO: DiscordUser) {
		self.playerX = playerX
		self.playerO = playerO
		startTime = Date()
		board = TicTacToeBoard()
	}
	
	func perform(moveBy role: TicTacToeRole, atRow row: Int, col: Int) throws {
		let next = try board.with(role, atRow: row, col: col)
		board = next
		currentPlayer = currentPlayer.opponent
	}
	
	func playerOf(role: TicTacToeRole) -> DiscordUser? {
		switch role {
			case .x: return playerX
			case .o: return playerO
			default: return nil
		}
	}
	
	func roleOf(player: DiscordUser) -> TicTacToeRole? {
		switch player.id {
			case playerX.id: return .x
			case playerO.id: return .o
			default: return nil
		}
	}
}
