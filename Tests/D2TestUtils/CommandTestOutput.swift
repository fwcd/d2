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
	
	public init() {}
	
	public func append(_ message: DiscordMessage) {
		internalMessages.append(message)
		changed = true
	}
}
