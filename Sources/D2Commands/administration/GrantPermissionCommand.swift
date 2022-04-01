import D2MessageIO
import D2Permissions
import Utils

fileprivate let inputPattern = try! Regex(from: "(?:(?:(?:<\\S+>)|(?:@\\S+))\\s+)+(.+)")

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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        if let parsedArgs = inputPattern.firstGroups(in: input) {
            let rawLevel = parsedArgs[1]
            if let level = PermissionLevel.of(rawLevel) {
                var response = ""
                var changedPermissions = false

                for mentionedUser in context.message.allMentionedUsers {
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
                output.append(errorText: "Unknown permission level `\(rawLevel)`")
            }
        } else {
            output.append(errorText: "Syntax error: The arguments need to match `[@user or role]* [permission level]`")
        }
    }
}
