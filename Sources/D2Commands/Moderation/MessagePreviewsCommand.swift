import D2MessageIO
import Utils

public class MessagePreviewsCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Enables/disables message previews",
        helpText: "Syntax: [enable|disable]",
        requiredPermissionLevel: .vip
    )
    @Binding private var configuration: MessagePreviewsConfiguration
    private var subcommands: [String: (CommandOutput, GuildID) async -> Void] = [:]

    public init(@Binding configuration: MessagePreviewsConfiguration) {
        self._configuration = _configuration
        subcommands = [
            "enable": { [unowned self] output, guildId in
                self.configuration.enabledGuildIds.insert(guildId)
                await output.append("Successfully enabled message previews on this guild!")
            },
            "disable": { [unowned self] output, guildId in
                self.configuration.enabledGuildIds.remove(guildId)
                await output.append("Successfully disabled message previews from this guild!")
            }
        ]
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let guildId = context.guild?.id else {
            await output.append(errorText: "Not on a guild")
            return
        }

        guard !input.isEmpty else {
            await output.append(errorText: "Please specify a subcommand: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))")
            return
        }

        guard let subcommand = subcommands[input] else {
            await output.append(errorText: "Unrecognized subcommand `\(input)`, try one of these: `\(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))`")
            return
        }

        await subcommand(output, guildId)
    }
}
