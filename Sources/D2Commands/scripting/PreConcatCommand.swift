import SwiftDiscord
import D2Permissions

public class PreConcatCommand: Command {
	public let description = "Concatenates the arguments with the input"
	public let inputValueType = "text"
	public let outputValueType = "text"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	private let separator = " "
	
	public init() {}
	
	public func invoke(withArgs args: String, input: RichValue, output: CommandOutput, context: CommandContext) {
		output.append("\(args)\(separator)\(input.asText ?? "")")
	}
}
