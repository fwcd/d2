import SwiftDiscord
import D2Permissions

public class ClosureCommand: Command {
	public let info: CommandInfo
	private let closure: (RichValue, CommandOutput, CommandContext) -> Void
	
	public init(info: CommandInfo, closure: @escaping (RichValue, CommandOutput, CommandContext) -> Void) {
		self.info = info
		self.closure = closure
	}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		self.closure(input, output, context)
	}
}
