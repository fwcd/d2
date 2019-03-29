import SwiftDiscord
import D2Permissions

public class TimeTableCommand: StringCommand {
	public let description = "Generates a TimeTable from CAU modules"
	public let requiredPermissionLevel = PermissionLevel.basic
	public let hidden = true
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		// TODO
	}
}
