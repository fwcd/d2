import SwiftDiscord
import D2Permissions

public class ClosureCommand: Command {
	public let description: String
	public let requiredPermissionLevel: PermissionLevel
	private let closure: (DiscordMessage?, CommandOutput, CommandContext, String) -> Void
	
	public init(
		description: String,
		level requiredPermissionLevel: PermissionLevel,
		closure: @escaping (DiscordMessage?, CommandOutput, CommandContext, String) -> Void
	) {
		self.description = description
		self.requiredPermissionLevel = requiredPermissionLevel
		self.closure = closure
	}
	
	public func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		self.closure(input, output, context, args)
	}
}
