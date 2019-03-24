import SwiftDiscord

class VoidCommand: Command {
	let description = "Does nothing."
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withInput input: DiscordMessage?, output: CommandOutput, context: CommandContext, args: String) {
		// Do nothing
	}
}
