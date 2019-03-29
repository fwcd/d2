import SwiftDiscord
import D2Permissions

/**
 * A command that only expects text-based input (as opposed to e.g. an input embed).
 * Usually, these are commands that expect exactly one argument.
 */
public protocol StringCommand: Command {
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext)
}

extension StringCommand {
	func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		invoke(withStringInput: (args.nilIfEmpty ?? input?.content) ?? "", output: output, context: context)
	}
}
