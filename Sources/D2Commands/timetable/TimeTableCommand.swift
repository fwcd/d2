import SwiftDiscord
import D2Permissions

public class TimeTableCommand: StringBasedCommand {
	public let description = "Generates a TimeTable from CAU modules"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	public let hidden = true
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		// TODO
	}
}
