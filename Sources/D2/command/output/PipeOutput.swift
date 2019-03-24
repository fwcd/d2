import SwiftDiscord

class PipeOutput: CommandOutput {
	private let sink: Command
	private let context: CommandContext
	private let args: String
	private let next: PipeOutput?
	
	init(withSink sink: Command, context: CommandContext, args: String, next: PipeOutput? = nil) {
		self.sink = sink
		self.args = args
		self.context = context
		self.next = next
	}
	
	func append(_ message: DiscordMessage) {
		sink.invoke(withInput: message, output: next ?? DiscordChannelOutput(message.channel), context: context, args: args)
	}
}
