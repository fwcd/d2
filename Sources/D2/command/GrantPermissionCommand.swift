import SwiftDiscord

fileprivate let argsPattern = try! Regex(from: "(?:(?:(?:<\\S+>)|(?:@\\S+))\\s*)+(.+)")

class GrantPermissionCommand: Command {
	let description = "Sets the permission level of a user"
	let requiredPermissionLevel = PermissionLevel.admin
	private let permissionManager: PermissionManager
	
	init(permissionManager: PermissionManager) {
		self.permissionManager = permissionManager
	}
	
	func invoke(withMessage message: DiscordMessage, guild: DiscordGuild?, args: String) {
		if let parsedArgs = argsPattern.firstGroups(in: args) {
			let rawLevel = parsedArgs[1]
			if let level = PermissionLevel.of(rawLevel) {
				var response = ""
				var changedPermissions = false
				
				for mentionedUser in message.mentions + resolve(roles: message.mentionRoles, mentionedEveryone: message.mentionEveryone, guild: guild) {
					permissionManager[mentionedUser] = level
					response += ":white_check_mark: Granted `\(mentionedUser.username)` \(rawLevel) permissions\n"
					changedPermissions = true
				}
				
				if changedPermissions {
					message.channel?.send(response)
					permissionManager.writeToDisk()
				} else {
					message.channel?.send("Did not change any permissions.")
				}
			} else {
				message.channel?.send("Unknown permission level `\(rawLevel)`")
			}
		} else {
			message.channel?.send("Syntax error: The arguments need to match `\(argsPattern.rawPattern)`")
		}
	}
	
	private func resolve(roles: [RoleID], mentionedEveryone: Bool, guild: DiscordGuild?) -> [DiscordUser] {
		if mentionedEveryone {
			return guild?.members.map { $0.value.user } ?? []
		} else {
			return roles.flatMap { role in
				guild?.members
					.map { $0.value }
					.filter { $0.roleIds.contains(role) }
					.map { $0.user }
					?? []
			}
		}
	}
}
