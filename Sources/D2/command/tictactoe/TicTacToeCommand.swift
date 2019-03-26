import SwiftDiscord

fileprivate let setMessageRegex = try! Regex(from: "set\\s+(\\S+)\\s+(\\S+)")

class TicTacToeCommand: StringCommand {
	let description = "Plays tic-tac-toe against someone"
	let requiredPermissionLevel = PermissionLevel.basic
	let subscribesToNextMessages = true
	
	var currentMatch: TicTacToeMatch? = nil
	
	private enum Row: String, CaseIterable {
		case top
		case center
		case bottom
		
		var index: Int {
			switch self {
				case .top: return 0
				case .center: return 1
				case .bottom: return 2
			}
		}
	}
	
	private enum Column: String, CaseIterable {
		case left
		case center
		case right
		
		var index: Int {
			switch self {
				case .left: return 0
				case .center: return 1
				case .right: return 2
			}
		}
	}
	
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard currentMatch == nil else {
			output.append("Wait for the current match to finish before creating a new one.")
			return
		}
		
		guard let opponent = context.message.mentions.first else {
			output.append("Mention an opponent to play against.")
			return
		}
		
		currentMatch = TicTacToeMatch(playerX: context.author, playerO: opponent)
		output.append("Playing new match against `\(opponent.username)`")
	}
	
	func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction {
		if let match = currentMatch {
			if let role = match.roleOf(player: context.author), let setArgs = setMessageRegex.firstGroups(in: content) {
				guard role == match.currentPlayer else {
					output.append("It is not your turn, `\(role)`")
					return .continueSubscription
				}
				
				let rowIndex: Int
				let colIndex: Int
				
				if let row = Row(rawValue: setArgs[1]), let col = Column(rawValue: setArgs[2]) {
					rowIndex = row.index
					colIndex = col.index
				} else if let row = Row(rawValue: setArgs[2]), let col = Column(rawValue: setArgs[1]) {
					rowIndex = row.index
					colIndex = col.index
				} else if let row = Int(setArgs[1]), let col = Int(setArgs[2]) {
					rowIndex = row
					colIndex = col
				} else {
					output.append("Invalid coordinates, try a combination of `\(Row.allCases.map { $0.rawValue })` and `\(Column.allCases.map { $0.rawValue })` with the syntax: `set [row] [column]` or `set [column] [row]`")
					return .continueSubscription
				}
				
				do {
					try match.perform(moveBy: role, atRow: rowIndex, col: colIndex)
					
					if let winner = match.board.winner {
						if let winnerPlayer = match.playerOf(role: winner) {
							output.append("\(winner.discordEncoded) aka. `\(winnerPlayer.username)` won the game!")
						} else {
							output.append("Invalid winner: \(winner.discordEncoded)")
						}
						
						return .cancelSubscription
					}
				} catch TicTacToeError.invalidMove(let role, let row, let col) {
					output.append("Invalid move by \(role.discordEncoded): Could not place at `[row = \(row), col = \(col)]`")
				} catch TicTacToeError.outOfBounds(let row, let col) {
					output.append("Out of bounds: `[row = \(row), col = \(col)]`")
				} catch {
					output.append("Error while attempting move")
					print(error)
				}
			}
		}
		return .continueSubscription
	}
}
