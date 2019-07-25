import SwiftDiscord
import D2Permissions

public class ConcatCommand: Command {
	public let description = "Concatenates the input with the arguments"
	public let inputValueType = "text"
	public let outputValueType = "text"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	private let separator = " "
	
	public init() {}
	
	public func invoke(withArgs args: String, input: RichValue, output: CommandOutput, context: CommandContext) {
		output.append("\((input.asText).map { "\($0)\(separator)" } ?? "")\(args)")
	}
}
