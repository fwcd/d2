import SwiftDiscord
import D2Utils

fileprivate let resetSubcommand = "reset"

public class SpammerRoleCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Sets the spammer role",
        longDescription: "Sets the role which is automatically assigned to spammers",
        requiredPermissionLevel: .admin
    )
    private let spamConfiguration: AutoSerializing<SpamConfiguration>
    
    public init(spamConfiguration: AutoSerializing<SpamConfiguration>) {
        self.spamConfiguration = spamConfiguration
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let guild = context.guild else { return }
        let mentions = context.message.mentionRoles
        
        guard mentions.count <= 1 else {
            output.append("Too many roles, please only mention one!")
            return
        }
        
        do {
            if let role = mentions.first {
                try spamConfiguration.update { $0.spammerRoles[guild.id] = role }
                output.append(":white_check_mark: Successfully updated the spammer role")
            } else if input == resetSubcommand {
                try spamConfiguration.update { $0.spammerRoles[guild.id] = nil }
                output.append(":white_check_mark: Successfully reset the spammer role")
            } else {
                output.append("The current spammer role is `\(spamConfiguration.value.spammerRoles[guild.id].flatMap { guild.roles[$0]?.name } ?? "nil")`")
            }
        } catch {
            print(error)
            output.append("Could not update spammer role")
        }
    }
}
