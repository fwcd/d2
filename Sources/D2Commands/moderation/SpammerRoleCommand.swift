import Logging
import D2MessageIO
import Utils

fileprivate let log = Logger(label: "D2Commands.SpammerRoleCommand")
fileprivate let resetSubcommand = "reset"

public class SpammerRoleCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Sets the spammer role",
        longDescription: "Sets the role which is automatically assigned to spammers",
        requiredPermissionLevel: .admin
    )
    @AutoSerializing private var spamConfiguration: SpamConfiguration

    public init(spamConfiguration: AutoSerializing<SpamConfiguration>) {
        self._spamConfiguration = spamConfiguration
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let guild = context.guild else { return }
        let mentions = context.message.mentionRoles

        guard mentions.count <= 1 else {
            output.append(errorText: "Too many roles, please only mention one!")
            return
        }

        if let role = mentions.first {
            spamConfiguration.spammerRoles[guild.id] = role
            output.append(":white_check_mark: Successfully updated the spammer role")
        } else if input == resetSubcommand {
            spamConfiguration.spammerRoles[guild.id] = nil
            output.append(":white_check_mark: Successfully reset the spammer role")
        } else {
            output.append("The current spammer role is `\(spamConfiguration.spammerRoles[guild.id].flatMap { guild.roles[$0]?.name } ?? "nil")`")
        }
    }
}
