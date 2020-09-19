import D2Utils
import D2MessageIO

public class HaikusCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Enables/disables Haikus in a channel",
        requiredPermissionLevel: .admin
    )
    @AutoSerializing private var configuration: HaikuConfiguration
    private var subcommands: [String: (CommandOutput, ChannelID) -> Void] = [:]

    public init(configuration: AutoSerializing<HaikuConfiguration>) {
        self._configuration = configuration

        subcommands = [
            "enable": { [unowned self] output, channelId in
                self.configuration.enabledChannelIds.insert(channelId)
                output.append("Enabled Haikus on this channel")
            },
            "disable": { [unowned self] output, channelId in
                self.configuration.enabledChannelIds.remove(channelId)
                output.append("Disabled Haikus on this channel")
            }
        ]
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let subcommand = subcommands[input] else {
            output.append(errorText: "Unrecognized subcommand, try one of these: `\(subcommands.keys.joined(separator: ", "))`")
            return
        }
        guard let channelId = context.channel?.id else {
            output.append(errorText: "Not in a channel")
            return
        }

        subcommand(output, channelId)
    }
}
