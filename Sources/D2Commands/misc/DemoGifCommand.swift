import SwiftDiscord
import D2Permissions
import D2Graphics
import D2Utils

public class DemoGifCommand: StringCommand {
	public let description = "Creates a demo GIF"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			let width = 200
			let height = 200
			var gif = AnimatedGif(width: UInt16(width), height: UInt16(height))
			
			let angleCount = 360
			let angle = Double.pi / 180.0
			
			for angleIndex in 0..<angleCount {
				let image = try Image(width: width, height: height)
				var graphics = CairoGraphics(fromImage: image)
				graphics.rotate(by: Double(angleIndex) * angle)
				graphics.draw(try Image(fromPngFile: "Resources/chess/whiteKnight.png"), at: Vec2(x: 100, y: 100))
				
				try gif.append(frame: image, delayTime: 100)
			}
			
			output.append(DiscordMessage(fromGif: gif, name: "demo.gif"))
		} catch {
			print(error)
			output.append("An error occurred while encoding/sending the image")
		}
	}
}
