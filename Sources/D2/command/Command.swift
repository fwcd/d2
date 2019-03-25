import SwiftDiscord

/** Encapsulates functionality that can conveniently be invoked using inputs and arguments. */
protocol Command {
	var description: String { get }
	var requiredPermissionLevel: PermissionLevel { get }
	var hidden: Bool { get }
	var subscribesToNextMessages: Bool { get }
	
	func invoke(withInput input: DiscordMessage?, output: CommandOutput, context: CommandContext, args: String)
	
	func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction
}

extension Command {
	var hidden: Bool { return false }
	var subscribesToNextMessages: Bool { return false }
	
	func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction {
		return .continueSubscription
	}
}
