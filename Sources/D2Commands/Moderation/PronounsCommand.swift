import Foundation
import Logging
import Utils
import D2MessageIO

private let customIdPrefix = "pronouns:"
private let log = Logger(label: "D2Commands.PronounsCommand")

public class PronounsCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Lets the user pick pronouns to be displayed as a role",
        requiredPermissionLevel: .basic
    )
    @Binding private var config: PronounRoleConfiguration

    public init(@Binding config: PronounRoleConfiguration) {
        self._config = _config
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard
            let guildId = await context.guild?.id,
            let pronounRoles = config.pronounRoles[guildId],
            !pronounRoles.isEmpty else {
            await output.append(errorText: "No pronoun mappings for this guild available!")
            return
        }

        do {
            try await output.append(.compound([
                .text("Please pick your pronouns:"),
                .components([.actionRow(.init(components:
                    pronounRoles
                        .sorted(by: descendingComparator(comparing: \.key))
                        .map { (name, roleId) in
                            let encodedIdData = try JSONEncoder().encode(roleId)
                            guard let encodedId = String(data: encodedIdData, encoding: .utf8) else {
                                throw EncodeError.couldNotEncode("Could not encoded pronoun role id (\(roleId))")
                            }
                            return .button(.init(
                                customId: "\(customIdPrefix)\(encodedId)",
                                label: name
                            ))
                        }
                ))]),
            ]))
            context.subscribeToChannel()
        } catch {
            await output.append(error, errorText: "Could not create pronoun picker message")
        }
    }

    public func onSubscriptionInteraction(with customId: String, by user: User, output: any CommandOutput, context: CommandContext) async {
        guard customId.hasPrefix(customIdPrefix) else { return }
        let encodedId = customId.dropFirst(customIdPrefix.count)
        guard let encodedIdData = encodedId.data(using: .utf8),
              let roleId = try? JSONDecoder().decode(RoleID.self, from: encodedIdData) else {
            log.error("Invalid pronoun role id: \(encodedId)")
            await output.append(errorText: "Could not add pronouns role due to invalid role id")
            return
        }
        guard let sink = context.sink else {
            await output.append(errorText: "Could not add pronouns role due to missing client")
            return
        }
        guard let guild = await context.guild else {
            await output.append(errorText: "Could not add pronouns role due to missing guild")
            return
        }

        do {
            let pronounRoles = [RoleID: String](uniqueKeysWithValues: self.config.pronounRoles[guild.id]?.map { ($0.value, $0.key) } ?? [])
            for otherRoleId in pronounRoles.keys where otherRoleId != roleId {
                try await sink.removeGuildMemberRole(otherRoleId, from: user.id, on: guild.id, reason: "Pronoun role switched")
            }
            let roleName = pronounRoles[roleId] ?? "?"
            do {
                try await sink.addGuildMemberRole(roleId, to: user.id, on: guild.id, reason: "Pronoun role added")
                await output.append("Switched your pronoun role to \(roleName)!")
            } catch {
                log.error("Could not add pronoun role \(roleName) (\(roleId)) to \(user.username) (\(user.id))")
            }
        } catch {
            log.error("Could not remove pronoun roles: \(error)")
        }
    }
}
