import SwiftDiscord

class TimeTableCommand: StringCommand {
	let description = "Generates a TimeTable from CAU modules"
	let requiredPermissionLevel = PermissionLevel.basic
	let hidden = true
	
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		// TODO
	}
}
