import D2Permissions

/**
 * A command that only expects text-based input (as opposed to e.g. an input embed).
 * Usually, these are commands that expect exactly one argument.
 */
public protocol StringCommand: Command {
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext)
}

extension StringCommand {
	public var inputValueType: RichValueType { return .text }
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		invoke(withStringInput: input.asText ?? input.asCode ?? "", output: output, context: context)
	}
}
