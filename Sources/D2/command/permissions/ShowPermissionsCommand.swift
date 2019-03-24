import SwiftDiscord

class ShowPermissionsCommand: Command {
	let description = "Displays the configured permissions"
	let requiredPermissionLevel = PermissionLevel.admin
	private let permissionManager: PermissionManager
	
	init(permissionManager: PermissionManager) {
		self.permissionManager = permissionManager
	}
	
	func invoke(withInput input: DiscordMessage?, output: CommandOutput, context: CommandContext, args: String) {
		output.append("```\n\(permissionManager.description)\n```")
	}
}
