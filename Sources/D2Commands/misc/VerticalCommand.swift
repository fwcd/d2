import SwiftDiscord
import D2Permissions

public class VerticalCommand: StringBasedCommand {
	public let description = "Reads horizontally, prints vertically"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		output.append(input.reduce("") { "\($0)\n\($1)" })
	}
}
