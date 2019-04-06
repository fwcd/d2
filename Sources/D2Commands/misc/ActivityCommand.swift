import SwiftDiscord
import D2Permissions
import D2Utils

fileprivate let activityTypes: [String: DiscordActivityType] = [
	"playing": .game,
	"streaming": .stream,
	"listening": .listening
]
fileprivate let argsPattern = try! Regex(from: "(\(activityTypes.keys.joined(separator: "|")))\\s+(.+)")

public class ActivityCommand: StringCommand {
	public let description = "Updates the game activity"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.admin
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		if let parsedArgs = argsPattern.firstGroups(in: input) {
			let activityType = activityTypes[parsedArgs[1]]!
			let customText = parsedArgs[2]
			
			guard let client = context.client else {
				output.append("No client found")
				return
			}
			
			client.setPresence(DiscordPresenceUpdate(game: DiscordActivity(name: customText, type: activityType)))
		} else {
			output.append("Syntax: [\(activityTypes.keys.joined(separator: "|"))] [custom text]")
		}
	}
}
