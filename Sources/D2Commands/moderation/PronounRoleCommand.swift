import Logging
import D2MessageIO
import Utils

fileprivate let log = Logger(label: "D2Commands.PronounRoleCommand")
fileprivate let resetSubcommand = "reset"

fileprivate let inputPattern = try! Regex(from: "([\\w\\/]+)(?:\\s+(\\d+))?")

public class PronounRoleCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Configures pronoun role mappings",
        helpText: "Syntax: [pronouns, e.g. They/Them] [role id]",
        requiredPermissionLevel: .admin
    )
    @Binding private var config: PronounRoleConfiguration

    public init(@Binding config: PronounRoleConfiguration) {
        self._config = _config
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard let guild = context.guild else {
            output.append(errorText: "No guild available")
            return
        }
        guard let sink = context.sink else {
            output.append(errorText: "No client available")
            return
        }
        guard let parsedInput = inputPattern.firstGroups(in: input) else {
            output.append(errorText: info.helpText!)
            return
        }
        let name = parsedInput[1]
        let rawRoleId = parsedInput[2].nilIfEmpty
        let roleId = rawRoleId.map { RoleID($0, clientName: sink.name) }

        var roles = config.pronounRoles[guild.id] ?? [:]
        roles[name] = roleId
        config.pronounRoles[guild.id] = roles

        output.append(":white_check_mark: Successfully updated the pronoun role for '\(name)' to \(roleId.map { "\($0)" } ?? "nil")")
    }
}

