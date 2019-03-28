import SwiftDiscord
import D2Utils

class DrawCommand: StringCommand {
	let description = "Creates a demo image"
	let requiredPermissionLevel = PermissionLevel.basic
	
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			var graphics = ImageGraphics(width: 150, height: 150)
			
			graphics.draw(LineSegment(fromX: 20, y: 20, toX: 50, y: 30))
			
			try output.append(graphics.image)
		} catch {
			print(error)
			output.append("An error occurred while encoding/sending the image")
		}
	}
}
