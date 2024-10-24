import D2MessageIO
import D2Permissions
import Utils

nonisolated(unsafe) private let inputPattern = #/(?:(?:<\S+>)|(?:@\S+))(?:\s+(?:(?:<\S+>)|(?:@\S+)))*\s*/#

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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        if input.matches(of: inputPattern).count > 0 {
            var response = ""
            var changedPermissions = false

            for mentionedUser in context.message.allMentionedUsers {
                await permissionManager.remove(permissionsFrom: mentionedUser)
                response += ":x: Revoked permissions from `\(mentionedUser.username)`\n"
                changedPermissions = true
            }

            if changedPermissions {
                await output.append(response)
                await permissionManager.writeToDisk()
            } else {
                await output.append("Did not change any permissions.")
            }
        } else {
            await output.append(errorText: "Syntax error: The arguments need to match `[@user or role]*`")
        }
    }
}
