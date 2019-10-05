import SwiftDiscord
import D2Permissions
import D2Graphics
import D2Utils

public class SpinCommand: Command {
	public let info = CommandInfo(
		category: .imaging,
		shortDescription: "Spins an image",
		longDescription: "Produces an animated GIF where each frame contains a rotation of the original image",
		requiredPermissionLevel: .basic
	)
	public let inputValueType: RichValueType = .image
	public let outputValueType: RichValueType = .gif
	private let frames: Int = 30
	
	public init() {}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		if case let .image(image) = input {
			do {
				let width = image.width
				let height = image.height
				var gif = AnimatedGif(width: UInt16(width), height: UInt16(height))
				
				let angle = (2.0 * Double.pi) / Double(frames)
				
				for frameIndex in 0..<frames {
					let rotatedImage = try Image(width: width, height: height)
					var graphics = CairoGraphics(fromImage: rotatedImage)
					
					graphics.draw(image, at: Vec2(x: 0, y: 0), rotation: angle * Double(frameIndex))
					
					try gif.append(frame: rotatedImage, delayTime: 2)
				}
				
				gif.appendTrailer()
				output.append(.gif(gif))
			} catch {
				print(error)
				output.append("Error while generating animation:\n`\(error)`")
			}
		} else {
			output.append("Error: Input is not an image")
		}
	}
}
