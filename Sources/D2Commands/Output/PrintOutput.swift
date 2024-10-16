import Logging

fileprivate let log = Logger(label: "D2Commands.PrintOutput")

public final class PrintOutput: CommandOutput, Sendable {
    public func append(_ value: RichValue, to channel: OutputChannel) {
        log.info("\(value) -> \(channel)")
    }

    public func update(context: CommandContext) {
        // Ignore
    }
}
