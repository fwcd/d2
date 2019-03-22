import SwiftDiscord

class VerticalCommand: Command {
	let description = "Reads horizontally, prints vertically"
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withMessage message: DiscordMessage, context: CommandContext, args: String) {
		message.channel?.send(args.reduce("") { "\($0)\n\($1)" })
	}
}
