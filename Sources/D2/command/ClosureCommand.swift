import SwiftDiscord

class ClosureCommand: Command {
	let description: String
	let requiredPermissionLevel: PermissionLevel
	private let closure: (DiscordMessage, String) -> Void
	
	init(
		description: String,
		level requiredPermissionLevel: PermissionLevel,
		closure: @escaping (DiscordMessage, String) -> Void
	) {
		self.description = description
		self.requiredPermissionLevel = requiredPermissionLevel
		self.closure = closure
	}
	
	func invoke(withMessage message: DiscordMessage, guild: DiscordGuild?, args: String) {
		self.closure(message, args)
	}
}
