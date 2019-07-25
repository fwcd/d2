import SwiftDiscord
import D2Permissions

public class LastMessageCommand: Command {
	public let description = "Retrieves and outputs the last message"
	public let inputValueType = "()"
	public let outputValueType = "any"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.vip
	
	public init() {}
	
	public func invoke(withArgs args: String, input: RichValue, output: CommandOutput, context: CommandContext) {
		context.client?.getMessages(for: context.channel!.id, limit: 2) { result, _ in
			if let lastMessage = result[safely: 1] {
				DiscordMessageParser().parse("", message: lastMessage) {
					output.append($0)
				}
			} else {
				output.append("Could not find last message.")
			}
		}
	}
}
