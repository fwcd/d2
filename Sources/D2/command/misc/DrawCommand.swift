import SwiftDiscord

class DrawCommand: StringCommand {
	let description = "Creates an image"
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		
	}
}
