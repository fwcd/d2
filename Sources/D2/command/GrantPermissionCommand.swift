import SwiftDiscord

fileprivate let argsPattern = try! Regex(from: "\\S+\\s*(.+)")

class GrantPermissionCommand: Command {
	let description = "Sets the permission level of a user"
	let requiredPermissionLevel = PermissionLevel.admin
	private let permissionManager: PermissionManager
	
	init(permissionManager: PermissionManager) {
		self.permissionManager = permissionManager
	}
	
	func invoke(withMessage message: DiscordMessage, args: String) {
		if let parsedArgs = argsPattern.firstGroups(in: args) {
			let rawLevel = parsedArgs[1]
			if let level = PermissionLevel.of(rawLevel) {
				if let mentionedUser = message.mentions.first {
					permissionManager[mentionedUser] = level
					message.channel?.send(":white_check_mark: Granted `\(mentionedUser.username)` \(rawLevel) permissions")
				} else {
					message.channel?.send("Please mention a user.")
				}
			} else {
				message.channel?.send("Unknown permission level `\(rawLevel)`")
			}
		} else {
			message.channel?.send("Syntax error: The arguments need to match \(argsPattern.rawPattern)")
		}
	}
}
