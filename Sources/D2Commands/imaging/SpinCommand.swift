import SwiftDiscord
import D2Permissions
import D2Graphics

public class SpinCommand: Command {
	public let description = "Animates a rotation of the image"
	public let helpText: String? = "Produces an animated GIF where each frame contains a rotated version of the input image"
	public let inputValueType = "image"
	public let outputValueType = "gif"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	private let frames: Int = 12
	
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
					
					graphics.rotate(by: angle * Double(frameIndex))
					graphics.draw(image)
					
					try gif.append(frame: rotatedImage, delayTime: 10)
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
