import D2MessageIO
import D2Graphics

public class ColorToAlphaCommand: Command {
	public let info = CommandInfo(
		category: .imaging,
		shortDescription: "Converts a color to transparency",
		requiredPermissionLevel: .basic
	)
	public let inputValueType: RichValueType = .image
	public let outputValueType: RichValueType = .image
	
	public init() {}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		if let img = input.asImage {
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
				output.append(error, errorText: "An error occurred while creating a new image")
			}
		} else {
			output.append(errorText: "Not an image!")
		}
	}
}
