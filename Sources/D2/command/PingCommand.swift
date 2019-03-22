import SwiftDiscord

class PingCommand: Command {
	let description = "Replies with 'Pong!'"
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withMessage message: DiscordMessage, context: CommandContext, args: String) {
		message.channel?.send("Pong!")
	}
}
