import Foundation
import Logging
import Utils
import D2MessageIO

fileprivate let customIdPrefix = "pronouns:"
fileprivate let log = Logger(label: "D2Commands.PronounsCommand")

public class PronounsCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Lets the user pick pronouns to be displayed as a role",
        requiredPermissionLevel: .basic
    )
    @Binding private var config: PronounRoleConfiguration

    public init(config _config: Binding<PronounRoleConfiguration>) {
        self._config = _config
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard
            let guildId = context.guild?.id,
            let pronounRoles = config.pronounRoles[guildId],
            !pronounRoles.isEmpty else {
            output.append(errorText: "No pronoun mappings for this guild available!")
            return
        }

        do {
            try output.append(.compound([.text("Please pick your pronouns:")] + pronounRoles.sorted(by: descendingComparator(comparing: \.key)).map { (name, roleId) in
                let encodedIdData = try JSONEncoder().encode(roleId)
                guard let encodedId = String(data: encodedIdData, encoding: .utf8) else {
                    throw EncodeError.couldNotEncode("Could not encoded pronoun role id (\(roleId))")
                }
                return RichValue.component(.button(.init(
                    customId: "\(customIdPrefix)\(encodedId)",
                    label: name
                )))
            }))
            context.subscribeToChannel()
        } catch {
            output.append(error, errorText: "Could not create pronoun picker message")
        }
    }

    public func onSubscriptionInteraction(with customId: String, by user: User, output: any CommandOutput, context: CommandContext) {
        guard customId.hasPrefix(customIdPrefix) else { return }
        let encodedId = customId.dropFirst(customIdPrefix.count)
        guard let encodedIdData = encodedId.data(using: .utf8),
              let roleId = try? JSONDecoder().decode(RoleID.self, from: encodedIdData) else {
            log.error("Invalid pronoun role id: \(encodedId)")
            output.append(errorText: "Could not add pronouns role due to invalid role id")
            return
        }
        guard let sink = context.sink else {
            output.append(errorText: "Could not add pronouns role due to missing client")
            return
        }
        guard let guild = context.guild else {
            output.append(errorText: "Could not add pronouns role due to missing guild")
            return
        }

        let pronounRoles = [RoleID: String](uniqueKeysWithValues: config.pronounRoles[guild.id]?.map { ($0.value, $0.key) } ?? [])
        for otherRoleId in pronounRoles.keys where otherRoleId != roleId {
            sink.removeGuildMemberRole(otherRoleId, from: user.id, on: guild.id, reason: "Pronoun role switched")
        }

        let roleName = pronounRoles[roleId] ?? "?"
        sink.addGuildMemberRole(roleId, to: user.id, on: guild.id, reason: "Pronoun role added").listen {
            output.append("Switched your pronoun role to \(roleName)!")
            if case .success(false) = $0 {
                log.warning("Could not add pronoun role \(roleName) (\(roleId)) to \(user.username) (\(user.id))")
            }
        }
    }
}
