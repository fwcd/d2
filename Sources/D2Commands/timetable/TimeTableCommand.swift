import SwiftDiscord
import D2Permissions

class TimeTableCommand: StringCommand {
	public let description = "Generates a TimeTable from CAU modules"
	public let requiredPermissionLevel = PermissionLevel.basic
	let hidden = true
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		// TODO
	}
}
