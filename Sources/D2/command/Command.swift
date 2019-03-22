import SwiftDiscord

protocol Command {
	var description: String { get }
	var requiredPermissionLevel: PermissionLevel { get }
	var hidden: Bool { get }
	
	func invoke(withMessage message: DiscordMessage, guild: DiscordGuild?, args: String)
}

extension Command {
	var hidden: Bool { return false }
}
