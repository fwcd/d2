import Utils

public class IndicatingOutput: CommandOutput {
    private let next: (any CommandOutput)?
    @Synchronized public private(set) var used: Bool = false

    public init(_ next: (any CommandOutput)? = nil) {
        self.next = next
    }

    public func append(_ value: RichValue, to channel: OutputChannel) async {
        used = true
        await next?.append(value, to: channel)
    }

    public func update(context: CommandContext) async {
        await next?.update(context: context)
    }
}
