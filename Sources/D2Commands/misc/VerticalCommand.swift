import SwiftDiscord
import D2Permissions

class VerticalCommand: StringCommand {
	let description = "Reads horizontally, prints vertically"
	let requiredPermissionLevel = PermissionLevel.basic
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		output.append(input.reduce("") { "\($0)\n\($1)" })
	}
}
