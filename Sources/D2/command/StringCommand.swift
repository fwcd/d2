import SwiftDiscord

/** A command that only expects text-based input (as opposed to e.g. an input embed). */
protocol StringCommand: Command {
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext)
}

extension StringCommand {
	func invoke(withInput input: DiscordMessage?, output: CommandOutput, context: CommandContext, args: String) {
		invoke(withStringInput: (args.nilIfEmpty ?? input?.content) ?? "", output: output, context: context)
	}
}
