import SwiftDiscord

class PipeOutput: CommandOutput {
	private let sink: Command
	private let context: CommandContext
	private let args: String
	private let next: CommandOutput?
	
	init(withSink sink: Command, context: CommandContext, args: String, next: CommandOutput? = nil) {
		self.sink = sink
		self.args = args
		self.context = context
		self.next = next
	}
	
	func append(_ message: DiscordMessage) {
		print("Piping to \(sink)")
		sink.invoke(withInput: message, output: next ?? DiscordChannelOutput(channel: message.channel), context: context, args: args)
	}
}
