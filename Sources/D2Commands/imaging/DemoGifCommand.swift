import Logging
import SwiftDiscord
import D2Permissions
import D2Graphics
import D2Utils

fileprivate let log = Logger(label: "DemoGifCommand")

public class DemoGifCommand: StringCommand {
	public let info = CommandInfo(
		category: .imaging,
		shortDescription: "Creates a demo GIF",
		longDescription: "Creates an animated GIF for testing purposes",
		requiredPermissionLevel: .basic
	)
	public let outputValueType: RichValueType = .gif
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			let width = 200
			let height = 200
			var gif = AnimatedGif(width: width, height: height)
			
			let angleCount = 4
			let angle = (2.0 * Double.pi) / Double(angleCount)
			
			for angleIndex in 0..<angleCount {
				log.info("Creating frame \(angleIndex) of \(angleCount)")
				
				let image = try Image(width: width, height: height)
				var graphics = CairoGraphics(fromImage: image)
				graphics.rotate(by: Double(angleIndex) * angle)
				graphics.draw(try Image(fromPngFile: "Resources/chess/whiteKnight.png"), at: Vec2(x: 100, y: 100))
				graphics.draw(Rectangle(fromX: 10, y: 10, width: 100, height: 100, rotation: Double(angleIndex) * angle, color: Colors.blue))
				
				gif.append(frame: .init(image: image, delayTime: 100))
			}
			
			output.append(.gif(gif))
		} catch {
			output.append(error, errorText: "An error occurred while encoding/sending the image")
		}
	}
}
