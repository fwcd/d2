import SwiftDiscord
import D2Permissions

public class TriggerTypingCommand: Command {
	public let description = "Begins to type"
	public let inputValueType: RichValueType = .none
	public let outputValueType: RichValueType = .none
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.vip
	
	public init() {}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		context.channel?.triggerTyping()
	}
}
