import SwiftDiscord
@testable import D2Commands

/**
 * An implementation of CommandOutput that writes
 * all messages into an array.
 */
public class CommandTestOutput: CommandOutput {
	private var internalMessages = [DiscordMessage]()
	
	/** Whether the output changed since the last read. */
	public private(set) var changed = false
	public var messages: [DiscordMessage] {
		changed = false
		return internalMessages
	}
	public var contents: [String] { return messages.map { $0.content } }
	public var last: DiscordMessage? { return messages.last }
	public var lastContent: String? { return last?.content }
	
	private let messageWriter = DiscordMessageWriter()
	
	public init() {}
	
	public func append(_ value: RichValue, to channel: OutputChannel) {
		internalMessages.append(try! messageWriter.write(value: value))
		changed = true
	}
	
	public func nthLast(_ n: Int = 1) -> DiscordMessage? {
		return messages[safely: messages.count - n]
	}
	
	public func nthLastContent(_ n: Int = 1) -> String? {
		return nthLast(n)?.content
	}
}
