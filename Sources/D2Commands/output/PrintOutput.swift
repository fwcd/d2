import SwiftDiscord
import Logging

fileprivate let log = Logger(label: "PrintOutput")

public class PrintOutput: CommandOutput {
	public func append(_ value: RichValue, to channel: OutputChannel) {
		log.info("\(value) -> \(channel)")
	}
}
