import SwiftDiscord
import D2Utils

class DrawCommand: StringCommand {
	let description = "Creates an image"
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			try output.append(Image(width: 300, height: 100))
		} catch {
			print(error)
			output.append("An error occurred while encoding/sending the image")
		}
	}
}
