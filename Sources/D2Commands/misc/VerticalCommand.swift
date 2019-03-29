import SwiftDiscord
import D2Permissions

public class VerticalCommand: StringCommand {
	public let description = "Reads horizontally, prints vertically"
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		output.append(input.reduce("") { "\($0)\n\($1)" })
	}
}
