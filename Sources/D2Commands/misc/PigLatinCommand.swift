import SwiftDiscord
import D2Permissions

public class PigLatinCommand: StringCommand {
	public let description = "Encodes a string in pig latin"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		// TODO
	}
}
