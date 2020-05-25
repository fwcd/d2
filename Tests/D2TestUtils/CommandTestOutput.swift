import D2MessageIO
@testable import D2Commands

/**
 * An implementation of CommandOutput that writes
 * all messages into an array.
 */
public class CommandTestOutput: CommandOutput {
	private var internalMessages = [Message]()
	
	/** Whether the output changed since the last read. */
	public private(set) var changed = false
	public var messages: [Message] {
		changed = false
		return internalMessages
	}
	public var contents: [String] { return messages.map { $0.content } }
	public var last: Message? { return messages.last }
	public var lastContent: String? { return last?.content }
	public var lastEmbedDescription: String? { return last?.embeds.first?.description }
	
	private let messageWriter = MessageWriter()
	
	public init() {}
	
	public func append(_ value: RichValue, to channel: OutputChannel) {
		messageWriter.write(value: value).listen {
			self.internalMessages.append(try! $0.get())
			self.changed = true
		}
	}

	public func update(context: CommandContext) {
		// Ignore
	}
	
	public func nthLast(_ n: Int = 1) -> Message? {
		return messages[safely: messages.count - n]
	}
	
	public func nthLastContent(_ n: Int = 1) -> String? {
		return nthLast(n)?.content
	}
}
