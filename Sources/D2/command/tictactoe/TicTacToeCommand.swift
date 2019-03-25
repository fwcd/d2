import SwiftDiscord

class TicTacToeCommand: StringCommand {
	let description = "Plays tic-tac-toe against someone"
	let requiredPermissionLevel = PermissionLevel.basic
	
	var currentMatch: TicTacToeMatch? = nil
	
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
		// TODO
		return .continueSubscription
	}
}
