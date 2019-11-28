import SwiftDiscord

fileprivate let resetSubcommand = "reset"

public class SpammerRoleCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Sets the spammer role",
        longDescription: "Sets the role which is automatically assigned to spammers",
        requiredPermissionLevel: .admin
    )
    private let spamConfiguration: SpamConfiguration
    
    public init(spamConfiguration: SpamConfiguration) {
        self.spamConfiguration = spamConfiguration
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let mentions = context.message.mentionRoles
        guard mentions.count <= 1 else {
            output.append("Too many roles, please only mention one!")
            return
        }

        if let role = mentions.first {
            spamConfiguration.spammerRole = role
            output.append(":white_check_mark: Successfully updated the spammer role")
        } else if input == resetSubcommand {
            spamConfiguration.spammerRole = nil
            output.append(":white_check_mark: Successfully reset the spammer role")
        } else {
            output.append("Please mention a role or use the `\(resetSubcommand)` subcommand")
        }
    }
}
