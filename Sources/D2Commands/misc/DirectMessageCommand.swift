import D2MessageIO
import D2Permissions
import D2Utils

fileprivate let inputPattern = try! Regex(from: "(?:(?:(?:<\\S+>)|(?:@\\S+))\\s+)+(.+)")

// TODO: Use Arg API

public class DirectMessageCommand: StringCommand {
	public let info = CommandInfo(
		category: .misc,
		shortDescription: "Sends a direct message to a user",
		longDescription: "Sends a direct message to a mentioned user",
		requiredPermissionLevel: .admin
	)
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard let parsedArgs = inputPattern.firstGroups(in: input) else {
			output.append(errorText: "Syntax error: `\(input)` should have format `[mentioned user] [message]`")
			return
		}
		guard let mentioned = context.message.mentions.first else {
			output.append(errorText: "Did not mention anyone")
			return
		}
		
		output.append(parsedArgs[1], to: .userChannel(mentioned.id))
	}
}
