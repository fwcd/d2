import SwiftDiscord
import D2Permissions

/** Encapsulates functionality that can conveniently be invoked using inputs and arguments. */
public protocol Command: class {
	var inputValueType: RichValueType { get }
	var outputValueType: RichValueType { get }
	var info: CommandInfo { get }
	
	func invoke(input: RichValue, output: CommandOutput, context: CommandContext)
	
	@discardableResult
	func on(event: CommandEvent) -> CommandSubscriptionAction?
	
	func equalTo(_ rhs: Command) -> Bool
}

extension Command {
	public var inputValueType: RichValueType { return .unknown }
	public var outputValueType: RichValueType { return .unknown }
	
	public func on(event: CommandEvent) -> CommandSubscriptionAction? { return nil }

	public func equalTo(_ rhs: Command) -> Bool {
		return self === rhs
	}
}
