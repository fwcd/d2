import SwiftDiscord
import D2Permissions

class TriggerTypingCommand: Command {
	let description = "Begins to type"
	let requiredPermissionLevel = PermissionLevel.vip
	
	func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		context.channel?.triggerTyping()
	}
}
