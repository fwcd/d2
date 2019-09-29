import SwiftDiscord
import D2Permissions

public class PingCommand: Command {
	public let description = "Replies with 'Pong!'"
	public let inputValueType: RichValueType = .none
	public let outputValueType: RichValueType = .text
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		output.append("Pong!")
	}
}
