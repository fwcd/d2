import SwiftDiscord
import D2Permissions

public class TriggerTypingCommand: Command {
	public let description = "Begins to type"
	public let requiredPermissionLevel = PermissionLevel.vip
	
	func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		context.channel?.triggerTyping()
	}
}
