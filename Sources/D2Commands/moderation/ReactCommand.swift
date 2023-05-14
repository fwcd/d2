import D2MessageIO
import Utils

fileprivate let argsPattern = try! Regex(from: "(\\d+)\\s+(\\d+)\\s+(\\S+)")

public class ReactCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Reacts to a message",
        helpText: "Syntax: [message id] [channel id] [emoji name]",
        requiredPermissionLevel: .admin
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let client = context.client else {
            output.append(errorText: "No client available")
            return
        }
        guard let parsedArgs = argsPattern.firstGroups(in: input) else {
            output.append(errorText: info.helpText!)
            return
        }
        let messageId = MessageID(parsedArgs[1], clientName: client.name)
        let channelId = MessageID(parsedArgs[2], clientName: client.name)
        let emoji = parsedArgs[3]
        client.createReaction(for: messageId, on: channelId, emoji: emoji)
    }
}
