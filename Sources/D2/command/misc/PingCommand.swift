import SwiftDiscord

class PingCommand: Command {
	let description = "Replies with 'Pong!'"
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withInput input: DiscordMessage?, output: CommandOutput, context: CommandContext, args: String) {
		output.append("Pong!")
	}
}
