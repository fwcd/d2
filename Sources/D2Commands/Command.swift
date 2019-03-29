import SwiftDiscord
import D2Permissions

/** Encapsulates functionality that can conveniently be invoked using inputs and arguments. */
protocol Command: class {
	var description: String { get }
	var requiredPermissionLevel: PermissionLevel { get }
	var hidden: Bool { get }
	var subscribesToNextMessages: Bool { get }
	
	func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext)
	
	func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction
}

extension Command {
	var hidden: Bool { return false }
	var subscribesToNextMessages: Bool { return false }
	
	func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction {
		return .continueSubscription
	}
}
