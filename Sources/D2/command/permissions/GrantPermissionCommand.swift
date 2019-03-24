import SwiftDiscord

fileprivate let argsPattern = try! Regex(from: "(?:(?:(?:<\\S+>)|(?:@\\S+))\\s+)+(.+)")

class GrantPermissionCommand: Command {
	let description = "Sets the permission level of one or more users"
	let requiredPermissionLevel = PermissionLevel.admin
	private let permissionManager: PermissionManager
	
	init(permissionManager: PermissionManager) {
		self.permissionManager = permissionManager
	}
	
	func invoke(withInput input: DiscordMessage?, output: CommandOutput, context: CommandContext, args: String) {
		if let parsedArgs = argsPattern.firstGroups(in: args) {
			let rawLevel = parsedArgs[1]
			if let level = PermissionLevel.of(rawLevel) {
				var response = ""
				var changedPermissions = false
				
				for mentionedUser in mentionedUsers(in: context.message, on: context.guild) {
					permissionManager[mentionedUser] = level
					response += ":white_check_mark: Granted `\(mentionedUser.username)` \(rawLevel) permissions\n"
					changedPermissions = true
				}
				
				if changedPermissions {
					output.append(response)
					permissionManager.writeToDisk()
				} else {
					output.append("Did not change any permissions.")
				}
			} else {
				output.append("Unknown permission level `\(rawLevel)`")
			}
		} else {
			output.append("Syntax error: The arguments need to match `[@user or role]* [permission level]`")
		}
	}
}
