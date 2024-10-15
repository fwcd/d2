import D2MessageIO
import D2Permissions
import Utils

public class GrantPermissionCommand: RegexCommand {
    public let info = CommandInfo(
        category: .administration,
        shortDescription: "Grants a user permissions",
        longDescription: "Sets the permission level of one or more users",
        helpText: "Syntax: [@user or role]* [permission level]",
        requiredPermissionLevel: .admin
    )
    public let inputPattern = #/(?:(?:(?:<\S+>)|(?:@\S+))\s+)+(?<level>.+)/#
    private let permissionManager: PermissionManager

    public init(permissionManager: PermissionManager) {
        self.permissionManager = permissionManager
    }

    public func invoke(with input: Input, output: any CommandOutput, context: CommandContext) async {
        let rawLevel = String(input.level)
        if let level = PermissionLevel.of(rawLevel) {
            var response = ""
            var changedPermissions = false

            for mentionedUser in context.message.allMentionedUsers {
                permissionManager[mentionedUser] = level
                response += ":white_check_mark: Granted `\(mentionedUser.username)` \(rawLevel) permissions\n"
                changedPermissions = true
            }

            if changedPermissions {
                await output.append(response)
                permissionManager.writeToDisk()
            } else {
                await output.append("Did not change any permissions.")
            }
        } else {
            await output.append(errorText: "Unknown permission level `\(rawLevel)`")
        }
    }
}
