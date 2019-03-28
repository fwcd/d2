import SwiftDiscord
import D2Utils

class DrawCommand: StringCommand {
	let description = "Creates a demo image"
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			let graphics = ImageGraphics(Image(width: 300, height: 300))
			// TODO
			try output.append(graphics.image)
		} catch {
			print(error)
			output.append("An error occurred while encoding/sending the image")
		}
	}
}
