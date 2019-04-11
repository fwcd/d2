import SwiftDiscord
import D2Permissions

public class ConcatCommand: Command {
	public let description = "Concatenates the input and arguments"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	private let separator = " "
	
	public init() {}
	
	public func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		output.append("\((input?.content).map { "\($0)\(separator)" } ?? "")\(args)")
	}
}
