import SwiftDiscord
import D2Permissions
import D2Graphics

public class InvertCommand: Command {
	public let description = "Inverts an image"
	public let helpText: String? = "Inverts the color of every pixel in the image"
	public let inputValueType = "image"
	public let outputValueType = "image"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		if case let .image(img) = input {
			do {
				let width = img.width
				let height = img.height
				var inverted = try Image(width: width, height: height)
				
				for y in 0..<height {
					for x in 0..<width {
						inverted[y, x] = img[y, x].inverted
					}
				}
				
				output.append(.image(inverted))
			} catch {
				output.append("An error occurred while creating a new image:\n`\(error)`")
			}
		} else {
			output.append("Error: Not an image!")
		}
	}
}
