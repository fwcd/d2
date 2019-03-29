import SwiftDiscord
import D2Permissions

public class LastMessageCommand: Command {
	public let description = "Retrieves and outputs the last message"
	public let requiredPermissionLevel = PermissionLevel.vip
	
	public func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		context.client?.getMessages(for: context.channel!.id, limit: 2) { result, _ in
			if let lastMessage = result[safely: 1] {
				output.append(lastMessage)
			} else {
				output.append("Could not find last message.")
			}
		}
	}
}
