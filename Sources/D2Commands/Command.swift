import D2MessageIO
import D2Permissions

/// Encapsulates functionality that can conveniently be invoked using inputs and arguments.
public protocol Command: class {
	var inputValueType: RichValueType { get }
	var outputValueType: RichValueType { get }
	var info: CommandInfo { get }
	
	/// Invokes this command with the given input. The command
	/// is usually expected to asynchronously produce some output.
	func invoke(input: RichValue, output: CommandOutput, context: CommandContext)

	/// Optionally creates a new command from "first applying the
	/// specified command, then this one". Although the result
	/// does not necessarily have to be the same as simply chaining
	/// the two commands using a piped output, it is generally
	/// expected to have a similar effect. Consider the following
	/// example:
	///
	///  - Chaining two animation commands would yield an animation
	///    where the second one operates on the _pixels_ of the first
	///    animation.
	///  - Composing two animation commands could yield an animation
	///    using the composition of both transformation functions,
	///    thereby producing a cleaner result.
	func compose(_ rhs: Command) -> Command?
	
	func onSuccessfullySent(context: CommandContext)
	
	func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext)

	func onSubscriptionReaction(emoji: Emoji, by user: User, output: CommandOutput, context: CommandContext)

	func onReceivedUpdated(presence: Presence)
	
	func equalTo(_ rhs: Command) -> Bool
}

extension Command {
	public var inputValueType: RichValueType { .unknown }
	public var outputValueType: RichValueType { .unknown }

	public func compose(_ rhs: Command) -> Command? { nil }
	
	public func onSuccessfullySent(context: CommandContext) {}
	
	public func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) {}

	public func onSubscriptionReaction(emoji: Emoji, by user: User, output: CommandOutput, context: CommandContext) {}

	// TODO: Support reaction removal
	
	public func onReceivedUpdated(presence: Presence) {}

	public func equalTo(_ rhs: Command) -> Bool { self === rhs }
}
