import SwiftDiscord
import D2Permissions

class PingCommand: Command {
	let description = "Replies with 'Pong!'"
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		output.append("Pong!")
	}
}
