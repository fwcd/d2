import Logging

fileprivate let log = Logger(label: "D2Commands.PipeOutput")

public class PipeOutput: CommandOutput {
	private let sink: Command
	private let args: String
	private let next: CommandOutput?

	private var context: CommandContext
	
	public init(withSink sink: Command, context: CommandContext, args: String, next: CommandOutput? = nil) {
		self.sink = sink
		self.args = args
		self.context = context
		self.next = next
	}
	
	public func append(_ value: RichValue, to channel: OutputChannel) {
		let nextOutput = next ?? PrintOutput()

		if case .error(_, _) = value {
			log.debug("Propagating error through pipe")
			nextOutput.append(value, to: channel)
		} else {
			log.debug("Piping to \(sink)")
			let nextInput = args.isEmpty ? value : (.text(args) + value)
			
			log.trace("Invoking sink")
			sink.invoke(input: nextInput, output: nextOutput, context: context)
		}
	}

	public func update(context: CommandContext) {
		self.context = context
		next?.update(context: context)
	}
}
