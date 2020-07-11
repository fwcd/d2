import D2MessageIO
import D2Permissions
import D2Utils

fileprivate let inputPattern = try! Regex(from: "(?:(?:<\\S+>)|(?:@\\S+))(?:\\s+(?:(?:<\\S+>)|(?:@\\S+)))*\\s*")

public class RevokePermissionCommand: StringCommand {
	public let info = CommandInfo(
		category: .administration,
		shortDescription: "Revokes a user permissions",
		longDescription: "Resets the permission level of one or more users",
		requiredPermissionLevel: .admin
	)
	private let permissionManager: PermissionManager
	
	public init(permissionManager: PermissionManager) {
		self.permissionManager = permissionManager
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		if inputPattern.matchCount(in: input) > 0 {
			var response = ""
			var changedPermissions = false
			
			for mentionedUser in context.message.allMentionedUsers {
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
			output.append(errorText: "Syntax error: The arguments need to match `[@user or role]*`")
		}
	}
}
