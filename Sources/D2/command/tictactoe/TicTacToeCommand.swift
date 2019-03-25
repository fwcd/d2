import SwiftDiscord

class TicTacToeCommand: Command {
	let description = "Plays tic-tac-toe against someone"
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withInput input: DiscordMessage?, output: CommandOutput, context: CommandContext, args: String) {
		// TODO
	}
}
