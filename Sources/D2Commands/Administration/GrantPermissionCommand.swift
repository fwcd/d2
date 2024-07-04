import D2MessageIO
import D2Permissions
import Utils

fileprivate let inputPattern = #/(?:(?:(?:<\S+>)|(?:@\S+))\s+)+(?<level>.+)/#

public class GrantPermissionCommand: StringCommand {
    public let info = CommandInfo(
        category: .administration,
        shortDescription: "Grants a user permissions",
        longDescription: "Sets the permission level of one or more users",
        requiredPermissionLevel: .admin
    )
    private let permissionManager: PermissionManager

    public init(permissionManager: PermissionManager) {
        self.permissionManager = permissionManager
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        if let parsedArgs = try? inputPattern.firstMatch(in: input) {
            let rawLevel = String(parsedArgs.level)
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
        } else {
            await output.append(errorText: "Syntax error: The arguments need to match `[@user or role]* [permission level]`")
        }
    }
}
