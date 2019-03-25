import SwiftDiscord

class TicTacToeCommand: StringCommand {
	let description = "Plays tic-tac-toe against someone"
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		// TODO
	}
	
	func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction {
		// TODO
		return .continueSubscription
	}
}
