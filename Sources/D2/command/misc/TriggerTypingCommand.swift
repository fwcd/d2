import SwiftDiscord

class TriggerTypingCommand: Command {
	let description = "Begins to type"
	let requiredPermissionLevel = PermissionLevel.vip
	
	func invoke(withMessage message: DiscordMessage, context: CommandContext, args: String) {
		message.channel?.triggerTyping()
	}
}
