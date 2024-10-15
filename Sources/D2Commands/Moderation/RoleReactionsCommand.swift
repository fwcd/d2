import D2MessageIO
import Utils

nonisolated(unsafe) private let emojiPattern = #/<a?:(.+):(\d+)>/#

public class RoleReactionsCommand: RegexCommand {
    public private(set) var info = CommandInfo(
        category: .moderation,
        shortDescription: "Adds reactions to a message that automatically assign roles",
        requiredPermissionLevel: .mod,
        platformAvailability: ["Discord"]
    )

    public let inputPattern = #/(?<subcommandName>\w+)\s+<#(?<channelId>\d+)>\s+(?<messageId>\d+)\s*(?<subcommandArgs>.*)/#

    @Binding private var configuration: RoleReactionsConfiguration
    private var subcommands: [String: (CommandOutput, Sink, ChannelID, MessageID, String) async -> Void] = [:]

    public init(@Binding configuration: RoleReactionsConfiguration) {
        self._configuration = _configuration
        subcommands = [
            "attach": { [unowned self] output, sink, channelId, messageId, args in
                guard let guild = sink.guildForChannel(channelId) else {
                    await output.append(errorText: "Not on a guild!")
                    return
                }
                guard !self.configuration.roleMessages.keys.contains(messageId) else {
                    await output.append(errorText: "Please detach this message first!")
                    return
                }

                do {
                    let mappings = try self.parseReactionMappings(from: args, on: guild)
                    self.configuration.roleMessages[messageId] = mappings

                    for (emoji, _) in mappings {
                        // TODO: Handle asynchronous errors properly
                        try await sink.createReaction(for: messageId, on: channelId, emoji: emoji)
                    }

                    await output.append("Successfully added role reactions to the message.")
                } catch {
                    await output.append(error, errorText: "Could not attach role reactions.")
                }
            },
            "detach": { [unowned self] output, sink, channelId, messageId, _ in
                guard let mappings = self.configuration.roleMessages[messageId] else {
                    await output.append(errorText: "This message is not a (known) reaction message!")
                    return
                }

                self.configuration.roleMessages[messageId] = nil

                do {
                    for (emoji, _) in mappings {
                        try await sink.deleteOwnReaction(for: messageId, on: channelId, emoji: emoji)
                    }

                    await output.append("Successfully removed role reactions from the message.")
                } catch {
                    await output.append(error, errorText: "Could not delete own reactions from the message")
                }
            }
        ]
        info.helpText = """
            Syntax: `[subcommand] [#channel] [message id] [args...]`

            For example:
            `attach #my-awesome-channel 123456789012345678 😁=Role a, 👍=Role b`
            `detach #my-awesome-channel 123456789012345678`
            """
    }

    public func invoke(with input: Input, output: any CommandOutput, context: CommandContext) async {
        guard let sink = context.sink else {
            await output.append(errorText: "No client available")
            return
        }

        let subcommandName = String(input.subcommandName)
        let channelId = ID(String(input.channelId), clientName: sink.name)
        let messageId = ID(String(input.messageId), clientName: sink.name)
        let subcommandArgs = String(input.subcommandArgs)

        guard let subcommand = subcommands[subcommandName] else {
            await output.append(errorText: "Unknown subcommand `\(subcommandName)`, try one of these: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))")
            return
        }

        await subcommand(output, sink, channelId, messageId, subcommandArgs)
    }

    private func parseReactionMappings(from s: String, on guild: Guild) throws -> RoleReactionsConfiguration.Mappings {
        let mappings = try s
            .split(separator: ",")
            .map { $0
                .split(separator: "=")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } }
            .map { try (parseEmoji(from: $0[0]), parseRoleId(from: $0[1], on: guild)) }

        return .init(roleMappings: Dictionary(uniqueKeysWithValues: mappings))
    }

    private func parseEmoji(from s: String) -> String {
        if let parsedEmoji = try? emojiPattern.firstMatch(in: s) {
            // Custom emoji reactions use a special syntax
            return "\(parsedEmoji.1):\(parsedEmoji.2)"
        } else {
            return s
        }
    }

    private func parseRoleId(from s: String, on guild: Guild) throws -> RoleID {
        for (roleId, role) in guild.roles {
            if s == "\(roleId)" || role.name == s {
                return role.id
            }
        }

        throw RoleReactionsError.couldNotParseRole(s)
    }
}
