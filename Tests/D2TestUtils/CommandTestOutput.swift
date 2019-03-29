import SwiftDiscord
@testable import D2Commands

/**
 * An implementation of CommandOutput that writes
 * all messages into an array.
 */
public class CommandTestOutput: CommandOutput {
	public private(set) var messages = [DiscordMessage]()
	
	public var contents: [String] { return messages.map { $0.content } }
	public var last: DiscordMessage? { return messages.last }
	public var lastContent: String? { return last?.content }
	
	public init() {}
	
	public func append(_ message: DiscordMessage) {
		messages.append(message)
	}
}
