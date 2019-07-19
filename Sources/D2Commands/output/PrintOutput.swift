public class PrintOutput: CommandOutput {
	public func append(_ value: RichValue, to channel: OutputChannel) {
		print("PrintOutput: \(value) -> \(channel)")
	}
}
