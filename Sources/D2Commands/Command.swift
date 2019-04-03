import SwiftDiscord
import D2Permissions

/** Encapsulates functionality that can conveniently be invoked using inputs and arguments. */
public protocol Command: class {
	var sourceFile: String { get }
	var description: String { get }
	var requiredPermissionLevel: PermissionLevel { get }
	var hidden: Bool { get }
	var subscribesToNextMessages: Bool { get }
	var userOnly: Bool { get }
	
	func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext)
	
	func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction
}

extension Command {
	public var hidden: Bool { return false }
	public var subscribesToNextMessages: Bool { return false }
	public var userOnly: Bool { return true }
	
	public func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction {
		return .continueSubscription
	}
}
