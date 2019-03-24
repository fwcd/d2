import SwiftDiscord

class TimeTableCommand: Command {
	let description = "Generates a TimeTable from CAU modules"
	let requiredPermissionLevel = PermissionLevel.basic
	let hidden = true
	
	func invoke(withInput input: DiscordMessage?, output: CommandOutput, context: CommandContext, args: String) {
		// TODO
	}
}
