import D2MessageIO
import D2Commands

extension Command {
	public func testInvoke(
		input: RichValue = .none,
		output: CommandOutput,
		context: CommandContext = CommandContext(guild: nil, registry: CommandRegistry(), message: Message(content: ""))
	) {
		invoke(input: input, output: output, context: context)
	}
	
	public func testSubscriptionMessage(
		withContent content: String,
		output: CommandOutput,
		context: CommandContext = CommandContext(guild: nil, registry: CommandRegistry(), message: Message(content: ""))
	) -> SubscriptionAction {
		return onSubscriptionMessage(withContent: content, output: output, context: context)
	}
}
