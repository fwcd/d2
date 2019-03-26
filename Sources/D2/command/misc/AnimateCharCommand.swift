import SwiftDiscord

class AnimateCharCommand: StringCommand {
	let description = "Animates a sequence of characters"
	let requiredPermissionLevel = PermissionLevel.vip
	private let loops = 4
	private let timer = RepeatingTimer(interval: .milliseconds(500))
	
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		// TODO
	}
}
