import Utils
import D2MessageIO

fileprivate let argPattern = #/(?:(?<platform>\w+)\s+)?(?<channelId>\d+)\s+(?<message>.+)/#

public class ChannelMessageCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Sends a message to an arbitrary channel on an arbitrary platform",
        helpText: "Syntax: [platform]? [channel id] [message]",
        requiredPermissionLevel: .vip
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let parsedArgs = try? argPattern.firstMatch(in: input) else {
            await output.append(errorText: info.helpText!)
            return
        }

        guard let platform = parsedArgs.platform.map({ String($0) }) ?? context.sink?.name else {
            await output.append(errorText: "No platform found")
            return
        }

        let rawId = String(parsedArgs.channelId)
        let message = String(parsedArgs.message)
        let id = ChannelID(rawId, clientName: platform)

        await output.append(message, to: .guildChannel(id))
    }
}
