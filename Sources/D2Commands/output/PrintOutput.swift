import SwiftDiscord

public class PrintOutput: CommandOutput {
	public func append(_ message: DiscordMessage, to channel: OutputChannel) {
		print("PrintOutput: \(message) -> \(channel)")
	}
}
