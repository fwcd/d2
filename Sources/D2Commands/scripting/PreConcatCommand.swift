import SwiftDiscord
import D2Permissions

public class PreConcatCommand: Command {
	public let description = "Concatenates the arguments with the input"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	private let separator = " "
	
	public init() {}
	
	public func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		output.append("\(args)\(separator)\(input?.content ?? "")")
	}
}
