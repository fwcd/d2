import SwiftDiscord
import D2Utils

class DrawCommand: StringCommand {
	let description = "Creates a demo image"
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			var graphics = ImageGraphics(width: 300, height: 300)
			
			graphics.draw(LineSegment(fromX: 0, y: 10, toX: 20, y: 20))
			
			try output.append(graphics.image)
		} catch {
			print(error)
			output.append("An error occurred while encoding/sending the image")
		}
	}
}
