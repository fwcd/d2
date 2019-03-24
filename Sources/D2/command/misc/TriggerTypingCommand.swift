import SwiftDiscord

class TriggerTypingCommand: Command {
	let description = "Begins to type"
	let requiredPermissionLevel = PermissionLevel.vip
	
	func invoke(withInput input: DiscordMessage?, output: CommandOutput, context: CommandContext, args: String) {
		context.channel?.triggerTyping()
	}
}
