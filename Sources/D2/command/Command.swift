import SwiftDiscord

protocol Command {
	var description: String { get }
	var requiredPermissionLevel: PermissionLevel { get }
	
	func invoke(withMessage message: DiscordMessage, guild: DiscordGuild?, args: String)
}
