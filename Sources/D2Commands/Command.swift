import SwiftDiscord
import D2Permissions

/** Encapsulates functionality that can conveniently be invoked using inputs and arguments. */
public protocol Command: class {
	var sourceFile: String { get }
	var description: String { get }
	var helpText: String? { get }
	var inputValueType: String { get }
	var outputValueType: String { get }
	var requiredPermissionLevel: PermissionLevel { get }
	var hidden: Bool { get }
	var subscribesToNextMessages: Bool { get }
	var userOnly: Bool { get }
	
	func invoke(input: RichValue, output: CommandOutput, context: CommandContext)
	
	func onSuccessfullySent(message: DiscordMessage)
	
	func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction
	
	func equalTo(_ rhs: Command) -> Bool
}

extension Command {
	public var hidden: Bool { return false }
	public var subscribesToNextMessages: Bool { return false }
	public var userOnly: Bool { return true }
	public var helpText: String? { return nil }
	public var inputValueType: String { return "?" }
	public var outputValueType: String { return "?" }
	
	public func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction {
		return .continueSubscription
	}
	
	public func onSuccessfullySent(message: DiscordMessage) {}

	public func equalTo(_ rhs: Command) -> Bool {
		return self === rhs
	}
}
