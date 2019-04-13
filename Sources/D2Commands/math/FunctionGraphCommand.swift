import SwiftDiscord
import D2Permissions

public class FunctionGraphCommand: StringCommand {
	public let description = "Plots the graph of a function"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		// TODO
	}
}
