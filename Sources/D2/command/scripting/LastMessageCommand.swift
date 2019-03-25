import SwiftDiscord

class LastMessageCommand: Command {
	let description = "Retrieves and outputs the last message"
	let requiredPermissionLevel = PermissionLevel.vip
	
	func invoke(withInput input: DiscordMessage?, output: CommandOutput, context: CommandContext, args: String) {
		context.client?.getMessages(for: context.channel!.id, limit: 2) { result, _ in
			if let lastMessage = result[safe: 1] {
				output.append(lastMessage)
			} else {
				output.append("Could not find last message.")
			}
		}
	}
}
