import SwiftDiscord
import D2Commands

extension Command {
	public func testInvoke(
		withArgs args: String,
		input: DiscordMessage? = nil,
		output: CommandOutput,
		context: CommandContext = CommandContext(guild: nil, registry: CommandRegistry(), message: DiscordMessage(content: ""))
	) {
		invoke(withArgs: args, input: input, output: output, context: context)
	}
}
