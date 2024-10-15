import Utils
import D2MessageIO

public class ChannelMessageCommand: RegexCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Sends a message to an arbitrary channel on an arbitrary platform",
        helpText: "Syntax: [platform]? [channel id] [message]",
        requiredPermissionLevel: .vip
    )

    public let inputPattern = #/(?:(?<platform>\w+)\s+)?(?<channelId>\d+)\s+(?<message>.+)/#

    public init() {}

    public func invoke(with input: Input, output: any CommandOutput, context: CommandContext) async {
        guard let platform = input.platform.map({ String($0) }) ?? context.sink?.name else {
            await output.append(errorText: "No platform found")
            return
        }

        let rawId = String(input.channelId)
        let message = String(input.message)
        let id = ChannelID(rawId, clientName: platform)

        await output.append(message, to: .guildChannel(id))
    }
}
