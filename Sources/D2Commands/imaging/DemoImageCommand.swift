import SwiftDiscord
import D2Permissions
import D2Utils
import D2Graphics

public class DemoImageCommand: StringCommand {
	public let info = CommandInfo(
		category: .imaging,
		shortDescription: "Creates a demo image",
		longDescription: "Creates a rendered image for testing purposes",
		requiredPermissionLevel: .basic
	)
	public let description = "Creates a demo image"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			let image = try Image(width: 200, height: 200)
			var graphics = CairoGraphics(fromImage: image)
			
			graphics.draw(LineSegment(fromX: 20, y: 20, toX: 50, y: 30))
			graphics.draw(Rectangle(fromX: 50, y: 50, width: 10, height: 35, color: Colors.yellow))
			graphics.draw(Rectangle(fromX: 80, y: 90, width: 10, height: 35, isFilled: false))
			graphics.draw(try Image(fromPngFile: "Resources/chess/whiteKnight.png"), at: Vec2(x: 20, y: 20))
			graphics.draw(Rectangle(fromX: 150, y: 150, width: 120, height: 120))
			graphics.draw(try Image(fromPngFile: "Resources/chess/whiteQueen.png"), at: Vec2(x: 120, y: 10), withSize: Vec2(x: 100, y: 100))
			graphics.draw(Text("Test", at: Vec2(x: 0, y: 15)))
			graphics.draw(Ellipse(centerX: 150, y: 80, radiusX: 40, y: 60, color: Colors.magenta, isFilled: false))
			graphics.draw(Ellipse(centerX: 120, y: 50, radius: 40, color: Colors.green))
			
			try output.append(image)
		} catch {
			print(error)
			output.append("An error occurred while encoding/sending the image")
		}
	}
}
