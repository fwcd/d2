import SwiftDiscord
import D2Permissions

public class VoidCommand: Command {
	public let description = "Does nothing."
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		// Do nothing
	}
}
