import SwiftDiscord

fileprivate let argsPattern = try! Regex(from: "(?:(?:<\\S+>)|(?:@\\S+))(?:\\s+(?:(?:<\\S+>)|(?:@\\S+)))*\\s*")

class RevokePermissionCommand: Command {
	let description = "Resets the permission level of one or more users"
	let requiredPermissionLevel = PermissionLevel.admin
	private let permissionManager: PermissionManager
	
	init(permissionManager: PermissionManager) {
		self.permissionManager = permissionManager
	}
	
	func invoke(withMessage message: DiscordMessage, context: CommandContext, args: String) {
		if argsPattern.matchCount(in: args) > 0 {
			var response = ""
			var changedPermissions = false
			
			for mentionedUser in mentionedUsers(in: message, on: context.guild) {
				permissionManager.remove(permissionsFrom: mentionedUser)
				response += ":x: Revoked permissions from `\(mentionedUser.username)`\n"
				changedPermissions = true
			}
			
			if changedPermissions {
				message.channel?.send(response)
				permissionManager.writeToDisk()
			} else {
				message.channel?.send("Did not change any permissions.")
			}
		} else {
			message.channel?.send("Syntax error: The arguments need to match `\(argsPattern.rawPattern)`")
		}
	}
}
