import Foundation
import SwiftDiscord

class TicTacToeMatch {
	private let startTime: Date
	var board: TicTacToeBoard
	let playerX: DiscordUser
	let playerO: DiscordUser
	
	var elapsedTime: TimeInterval {
		return -startTime.timeIntervalSinceNow
	}
	
	init(playerX: DiscordUser, playerO: DiscordUser) {
		self.playerX = playerX
		self.playerO = playerO
		startTime = Date()
		board = TicTacToeBoard()
	}
}
