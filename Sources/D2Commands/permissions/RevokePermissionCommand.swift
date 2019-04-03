import SwiftDiscord
import D2Permissions
import D2Utils

fileprivate let inputPattern = try! Regex(from: "(?:(?:<\\S+>)|(?:@\\S+))(?:\\s+(?:(?:<\\S+>)|(?:@\\S+)))*\\s*")

public class RevokePermissionCommand: StringCommand {
	public let description = "Resets the permission level of one or more users"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.admin
	private let permissionManager: PermissionManager
	
	public init(permissionManager: PermissionManager) {
		self.permissionManager = permissionManager
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		if inputPattern.matchCount(in: input) > 0 {
			var response = ""
			var changedPermissions = false
			
			for mentionedUser in mentionedUsers(in: context.message, on: context.guild) {
				permissionManager.remove(permissionsFrom: mentionedUser)
				response += ":x: Revoked permissions from `\(mentionedUser.username)`\n"
				changedPermissions = true
			}
			
			if changedPermissions {
				output.append(response)
				permissionManager.writeToDisk()
			} else {
				output.append("Did not change any permissions.")
			}
		} else {
			output.append("Syntax error: The arguments need to match `[@user or role]*`")
		}
	}
}
