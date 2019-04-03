import SwiftDiscord
import D2Permissions

fileprivate let repositoryUrl = "https://github.com/fwcd/D2"

public class SourceFileCommand: StringCommand {
	public let description = "Fetches the source code for a command"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard let command = context.registry[input] else {
			output.append("Unknown command `\(input)`")
			return
		}
		
		guard let relativePath = command.sourceFile.components(separatedBy: "Sources/").last else {
			output.append("Could not locate source file for command `\(input)`")
			return
		}
		
		output.append("\(repositoryUrl)/tree/master/Sources/\(relativePath)")
	}
}
