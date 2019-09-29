import SwiftDiscord
import D2Permissions

/**
 * A command that only expects text-based input (as opposed to e.g. an input embed).
 * Usually, these are commands that expect exactly one argument.
 */
public protocol StringBasedCommand {
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext)
}

/**
 * A wrapper class that conforms to `Command`
 * and converts the rich input value to a string.
 */
public class StringCommand<C>: Command where C: StringBasedCommand {
	private let inner: C
	
	public init(_ inner: C) { self.inner = inner }

	public var inputValueType: String { return "text" }
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		inner.invoke(withStringInput: input.asText ?? "", output: output, context: context)
	}
}
