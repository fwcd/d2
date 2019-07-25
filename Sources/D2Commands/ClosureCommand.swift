import SwiftDiscord
import D2Permissions

public class ClosureCommand: Command {
	public let description: String
	public let sourceFile: String = #file
	public let requiredPermissionLevel: PermissionLevel
	private let closure: (RichValue, CommandOutput, CommandContext) -> Void
	
	public init(
		description: String,
		level requiredPermissionLevel: PermissionLevel,
		closure: @escaping (RichValue, CommandOutput, CommandContext) -> Void
	) {
		self.description = description
		self.requiredPermissionLevel = requiredPermissionLevel
		self.closure = closure
	}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		self.closure(input, output, context)
	}
}
