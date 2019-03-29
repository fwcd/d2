import SwiftDiscord
import D2Permissions

class VoidCommand: Command {
	let description = "Does nothing."
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		// Do nothing
	}
}
