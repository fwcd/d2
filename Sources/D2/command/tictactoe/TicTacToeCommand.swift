import SwiftDiscord

class TicTacToeCommand: Command {
	let description = "Plays tic-tac-toe against someone"
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		// TODO
	}
}
