import SwiftDiscord
import D2Permissions

public class MarkovCommand: StringCommand {
	public let description = "Generates a natural language response using a Markov chain"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard let channelId = context.channel?.id else {
			output.append("Could not figure out the channel we are on")
			return
		}
		guard let client = context.client else {
			output.append("MarkovCommand can not be invoked without a client")
			return
		}
		
		client.getMessages(for: channelId, selection: nil, limit: 80) { _, _ in
			
		}
	}
}
