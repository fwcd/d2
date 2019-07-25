import SwiftDiscord

public class PipeOutput: CommandOutput {
	private let sink: Command
	private let context: CommandContext
	private let args: String
	private let next: CommandOutput?
	
	public init(withSink sink: Command, context: CommandContext, args: String, next: CommandOutput? = nil) {
		self.sink = sink
		self.args = args
		self.context = context
		self.next = next
	}
	
	public func append(_ value: RichValue, to channel: OutputChannel) {
		print("Piping to \(sink)")
		let nextInput = args.isEmpty ? value : (.text(args) + value)
		sink.invoke(input: nextInput, output: next ?? PrintOutput(), context: context)
	}
}
