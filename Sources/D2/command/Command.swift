import SwiftDiscord

protocol Command {
	var description: String { get }
	var requiredPermissionLevel: PermissionLevel { get }
	
	func invoke(withMessage message: DiscordMessage, args: String)
}
