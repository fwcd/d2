import SwiftDiscord

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
	
	func invoke(withInput input: DiscordMessage?, output: CommandOutput, context: CommandContext, args: String) {
		self.closure(input, output, context, args)
	}
}
