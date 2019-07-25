import SwiftDiscord
import D2Permissions

public class TriggerTypingCommand: Command {
	public let description = "Begins to type"
	public let inputValueType = "()"
	public let outputValueType = "()"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.vip
	
	public init() {}
	
	public func invoke(withArgs args: String, input: RichValue, output: CommandOutput, context: CommandContext) {
		context.channel?.triggerTyping()
	}
}
