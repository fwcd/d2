import D2Utils

public class IndicatingOutput: CommandOutput {
    private let next: CommandOutput?
    @Synchronized public private(set) var used: Bool = false

    public init(_ next: CommandOutput? = nil) {
        self.next = next
    }

    public func append(_ value: RichValue, to channel: OutputChannel) {
        used = true
        next?.append(value, to: channel)
    }

    public func update(context: CommandContext) {
        next?.update(context: context)
    }
}
