import SwiftDiscord

/** Encapsulates functionality that can conveniently be invoked using inputs and arguments. */
protocol Command {
	var description: String { get }
	var requiredPermissionLevel: PermissionLevel { get }
	var hidden: Bool { get }
	
	func invoke(withInput input: DiscordMessage?, output: CommandOutput, context: CommandContext, args: String)
}

extension Command {
	var hidden: Bool { return false }
}
