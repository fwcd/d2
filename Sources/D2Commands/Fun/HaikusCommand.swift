import Utils
import D2MessageIO

public class HaikusCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Enables/disables Haikus in a channel",
        requiredPermissionLevel: .admin
    )
    @Binding private var configuration: HaikuConfiguration
    private var subcommands: [String: (CommandOutput, ChannelID) async -> Void] = [:]

    public init(@Binding configuration: HaikuConfiguration) {
        self._configuration = _configuration

        subcommands = [
            "enable": { [unowned self] output, channelId in
                self.configuration.enabledChannelIds.insert(channelId)
                await output.append("Enabled Haikus on this channel")
            },
            "disable": { [unowned self] output, channelId in
                self.configuration.enabledChannelIds.remove(channelId)
                await output.append("Disabled Haikus on this channel")
            }
        ]
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let subcommand = subcommands[input] else {
            await output.append(errorText: "Unrecognized subcommand, try one of these: `\(subcommands.keys.joined(separator: ", "))`")
            return
        }
        guard let channelId = context.channel?.id else {
            await output.append(errorText: "Not in a channel")
            return
        }

        await subcommand(output, channelId)
    }
}
