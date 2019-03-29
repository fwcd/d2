import SwiftDiscord
@testable import D2

/**
 * An implementation of CommandOutput that writes
 * all messages into an array.
 */
public class CommandTestOutput: CommandOutput {
	public private(set) var messages = [DiscordMessage]()
	public var last: DiscordMessage? { return messages.last }
	
	public func append(_ message: DiscordMessage) {
		messages.append(message)
	}
}
