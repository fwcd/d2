import Logging
import SwiftDiscord
import D2Permissions
import D2Graphics
import D2Utils

fileprivate let log = Logger(label: "SpinCommand")

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
				var gif = AnimatedGif(quantizingImage: image)
				
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
				output.append(error, errorText: "Error while generating animation")
			}
		} else {
			output.append(errorText: "Input is not an image")
		}
	}
}
