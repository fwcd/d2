import SwiftDiscord
import D2Permissions

public class VoidCommand: Command {
	public let description = "Does nothing."
	public let inputValueType = "()"
	public let outputValueType = "()"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withArgs args: String, input: RichValue, output: CommandOutput, context: CommandContext) {
		// Do nothing
	}
}
