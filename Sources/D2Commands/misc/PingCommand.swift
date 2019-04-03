import SwiftDiscord
import D2Permissions

public class PingCommand: Command {
	public let description = "Replies with 'Pong!'"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		output.append("Pong!")
	}
}
