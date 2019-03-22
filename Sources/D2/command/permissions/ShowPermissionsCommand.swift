import SwiftDiscord

class ShowPermissionsCommand: Command {
	let description = "Displays the permissions"
	let requiredPermissionLevel = PermissionLevel.admin
	private let permissionManager: PermissionManager
	
	init(permissionManager: PermissionManager) {
		self.permissionManager = permissionManager
	}
	
	func invoke(withMessage message: DiscordMessage, guild: DiscordGuild?, args: String) {
		message.channel?.send("```\n\(permissionManager.description)\n```")
	}
}
