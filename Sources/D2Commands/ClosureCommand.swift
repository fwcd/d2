import SwiftDiscord
import D2Permissions

class ClosureCommand: Command {
	let description: String
	let requiredPermissionLevel: PermissionLevel
	private let closure: (DiscordMessage?, CommandOutput, CommandContext, String) -> Void
	
	init(
		description: String,
		level requiredPermissionLevel: PermissionLevel,
		closure: @escaping (DiscordMessage?, CommandOutput, CommandContext, String) -> Void
	) {
		self.description = description
		self.requiredPermissionLevel = requiredPermissionLevel
		self.closure = closure
	}
	
	func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		self.closure(input, output, context, args)
	}
}
