import SwiftDiscord
import D2Permissions

public class LatexCommand: StringCommand {
	public let description = "Renders a LaTeX string"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		
	}
}
