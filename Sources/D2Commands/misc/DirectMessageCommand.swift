import SwiftDiscord
import D2Permissions
import D2Utils

fileprivate let inputPattern = try! Regex(from: "(?:(?:(?:<\\S+>)|(?:@\\S+))\\s+)+(.+)")

public class DirectMessageCommand: StringCommand {
	public let description = "Sends a direct message to a user"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.admin
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard let parsedArgs = inputPattern.firstGroups(in: input) else {
			output.append("Syntax error: `\(input)` should have format `[mentioned user] [message]`")
			return
		}
		guard let mentioned = context.message.mentions.first else {
			output.append("Did not mention anyone")
			return
		}
		
		output.append(parsedArgs[1], to: .userChannel(mentioned.id))
	}
}
