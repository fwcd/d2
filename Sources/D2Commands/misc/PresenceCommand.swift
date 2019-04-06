import SwiftDiscord
import D2Permissions
import D2Utils

fileprivate let activityTypes: [String: DiscordActivityType] = [
	"playing": .game,
	"streaming": .stream,
	"listening": .listening
]
fileprivate let argsPattern = try! Regex(from: "(\(activityTypes.keys.joined(separator: "|")))\\s+(?:(idle|offline|online|dnd)\\s+)?(.+)")

public class PresenceCommand: StringCommand {
	public let description = "Updates the game activity and status"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.admin
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		if let parsedArgs = argsPattern.firstGroups(in: input) {
			let activityType = activityTypes[parsedArgs[1]]!
			let status = parsedArgs[2].nilIfEmpty.flatMap { DiscordPresenceStatus(rawValue: $0) } ?? .online
			let customText = parsedArgs[3]
			
			guard let client = context.client else {
				output.append("No client found")
				return
			}
			
			client.setPresence(DiscordPresenceUpdate(game: DiscordActivity(name: customText, type: activityType), status: status))
		} else {
			output.append("Syntax: [\(activityTypes.keys.joined(separator: "|"))] [custom text]")
		}
	}
}
