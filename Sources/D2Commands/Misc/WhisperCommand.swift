import Utils

public class WhisperCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Toggles whisper mode in the current channel"
    )
    @Binding private var configuration: WhisperConfiguration

    public init(@Binding configuration: WhisperConfiguration) {
        self._configuration = _configuration
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let channelId = context.channel?.id else {
            await output.append(errorText: "Toggling whisper mode requires a channel")
            return
        }

        if configuration.enabledChannelIds.contains(channelId) {
            configuration.enabledChannelIds.remove(channelId)
            await output.append("Disabled whisper mode on this channel")
        } else {
            configuration.enabledChannelIds.insert(channelId)
            await output.append("Enabled whisper mode on this channel")
        }
    }
}
