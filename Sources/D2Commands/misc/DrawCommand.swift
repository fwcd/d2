import SwiftDiscord
import D2Permissions
import D2Utils

public class DrawCommand: StringCommand {
	public let description = "Creates a demo image"
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			var graphics = ImageGraphics(width: 150, height: 150)
			
			graphics.draw(LineSegment(fromX: 20, y: 20, toX: 50, y: 30))
			graphics.draw(Rectangle(fromX: 50, y: 50, width: 10, height: 35, color: Colors.yellow))
			graphics.draw(Rectangle(fromX: 80, y: 90, width: 10, height: 35, isFilled: false))
			graphics.draw(try Image(fromFile: "Resources/chess/whiteKnight.png"))
			
			try output.append(graphics.image)
		} catch {
			print(error)
			output.append("An error occurred while encoding/sending the image")
		}
	}
}
