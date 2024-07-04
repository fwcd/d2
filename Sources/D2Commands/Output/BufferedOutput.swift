import Logging

private let log = Logger(label: "D2Commands.BufferedOutput")

/// A buffered output that accumulates RichValues and first outputs once
/// flushed (or deinited, in which case it happens automatically).
public class BufferedOutput: CommandOutput {
    private let inner: any CommandOutput
    private var buffer: [OutputChannel: [RichValue]] = [:]
    public var messageLengthLimit: Int? { inner.messageLengthLimit }

    public init(_ inner: any CommandOutput) {
        self.inner = inner
    }

    public func append(_ value: RichValue, to channel: OutputChannel) {
        buffer[channel] = (buffer[channel] ?? []) + [value]
    }

    public func update(context: CommandContext) {
        inner.update(context: context)
    }

    public func flush() async {
        if !buffer.isEmpty {
            for (channel, values) in buffer {
                await inner.append(.compound(values), to: channel)
            }
            buffer = [:]
        }
    }

    deinit {
        if !buffer.isEmpty {
            log.warning("BufferedOutput contained \(buffer.count) \("value".pluralized(with: buffer.count)) at deinitialization, which will now be flushed automatically. This may sometimes lead to unexpected behavior, since the outputs may be appended asynchronously/out-of-order. It is recommended to .flush() and await explicitly.")

            Task {
                for (channel, values) in buffer {
                    await inner.append(.compound(values), to: channel)
                }
                buffer = [:]
            }
        }
    }
}
