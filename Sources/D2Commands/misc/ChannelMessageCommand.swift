import Utils
import D2MessageIO

fileprivate let argPattern = try! Regex(from: "(?:(\\w+)\\s+)?(\\d+)\\s+(.+)")

public class ChannelMessageCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Sends a message to an arbitrary channel on an arbitrary platform",
        helpText: "Syntax: [platform]? [channel id] [message]",
        requiredPermissionLevel: .vip
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let parsedArgs = argPattern.firstGroups(in: input) else {
            output.append(errorText: info.helpText!)
            return
        }

        guard let platform = parsedArgs[1].nilIfEmpty ?? context.client?.name else {
            output.append(errorText: "No platform found")
            return
        }

        let rawId = parsedArgs[2]
        let message = parsedArgs[3]
        let id = ChannelID(rawId, clientName: platform)

        output.append(message, to: .guildChannel(id))
    }
}
