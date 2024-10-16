import Logging

fileprivate let log = Logger(label: "D2Commands.PipeOutput")

public class PipeOutput: CommandOutput {
    private let sink: any Command
    private let args: String
    private let next: (any CommandOutput)?
    private var context: CommandContext

    private let msgParser = MessageParser()

    public init(withSink sink: any Command, context: CommandContext, args: String, next: (any CommandOutput)? = nil) {
        self.sink = sink
        self.args = args
        self.context = context
        self.next = next
    }

    public nonisolated func append(_ value: RichValue, to channel: OutputChannel) async {
        let nextOutput = next ?? PrintOutput()

        if case .error(_, _) = value {
            log.debug("Propagating error through pipe")
            await nextOutput.append(value, to: channel)
        } else {
            log.debug("Piping to \(sink)")
            let argsValue = await msgParser.parse(args, clientName: context.sink?.name, guild: context.guild)
            let nextInput = argsValue + value
            log.trace("Invoking sink")
            await self.sink.invoke(with: nextInput, output: nextOutput, context: self.context)
        }
    }

    public func update(context: CommandContext) async {
        self.context = context
        await next?.update(context: context)
    }
}
