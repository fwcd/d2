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
    private var subcommands: [String: (CommandOutput, GuildID) -> Void] = [:]

    public init(configuration: Binding<MessagePreviewsConfiguration>) {
        self._configuration = configuration
        subcommands = [
            "enable": { [unowned self] output, guildId in
                self.configuration.enabledGuildIds.insert(guildId)
                output.append("Successfully enabled message previews on this guild!")
            },
            "disable": { [unowned self] output, guildId in
                self.configuration.enabledGuildIds.remove(guildId)
                output.append("Successfully disabled message previews from this guild!")
            }
        ]
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard let guildId = context.guild?.id else {
            output.append(errorText: "Not on a guild")
            return
        }

        if let subcommand = subcommands[input] {
            subcommand(output, guildId)
        } else {
            output.append(errorText: "Unrecognized subcommand `\(input)`, try one of these: `\(subcommands.keys.joined(separator: ", "))`")
        }
    }
}
