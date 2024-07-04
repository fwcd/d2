import D2MessageIO
import D2Permissions
import Utils

fileprivate let inputPattern = #/(?:(?:(?:<\S+>)|(?:@\S+))\s+)+(.+)/#

// TODO: Use Arg API

public class DirectMessageCommand: Command {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Sends a direct message to a user",
        longDescription: "Sends a direct message to a mentioned user",
        requiredPermissionLevel: .admin
    )
    public let inputValueType: RichValueType = .mentions
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        let text = input.asText ?? ""
        guard let parsedArgs = try? inputPattern.firstMatch(in: text) else {
            await output.append(errorText: "Syntax error: `\(input)` should have format `[mentioned user] [message]`")
            return
        }
        guard let mentioned = input.asMentions?.first else {
            await output.append(errorText: "Did not mention anyone")
            return
        }

        await output.append(String(parsedArgs.1), to: .dmChannel(mentioned.id))
    }
}
