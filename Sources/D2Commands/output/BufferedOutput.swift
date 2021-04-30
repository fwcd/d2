/// A buffered output that accumulates RichValues and first outputs once
/// flushed (or deinited, in which case it happens automatically).
public class BufferedOutput: CommandOutput {
    private let inner: CommandOutput
    private var buffer: [OutputChannel: [RichValue]] = [:]
    public var messageLengthLimit: Int? { inner.messageLengthLimit }

    public init(_ inner: CommandOutput) {
        self.inner = inner
    }

    public func append(_ value: RichValue, to channel: OutputChannel) {
        buffer[channel] = (buffer[channel] ?? []) + [value]
    }

    public func update(context: CommandContext) {
        inner.update(context: context)
    }

    public func flush() {
        if !buffer.isEmpty {
            for (channel, values) in buffer {
                inner.append(.compound(values), to: channel)
            }
            buffer = [:]
        }
    }

    deinit {
        flush()
    }
}
