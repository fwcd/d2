import D2MessageIO
import D2Graphics

public class ScaleCommand: Command {
	public let info = CommandInfo(
		category: .imaging,
		shortDescription: "Scales an image by a factor",
		requiredPermissionLevel: .basic
	)
	public let inputValueType: RichValueType = .compound([.image, .text])
	public let outputValueType: RichValueType = .image

	public init() {}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		guard let img = input.asImage else {
			output.append(errorText: "Not an image!")
            return
        }

        guard let rawFactor = input.asText,
            let factor = Double(rawFactor) else {
            output.append(errorText: "Please enter a scaling factor!")
            return
        }

        do {
            let width = Int(Double(img.width) * factor)
            let height = Int(Double(img.height) * factor)
            var scaled = try Image(width: width, height: height)
            
            for y in 0..<height {
                for x in 0..<width {
                    scaled[y, x] = img[Int(Double(y) / factor), Int(Double(x) / factor)]
                }
            }
            
            output.append(.image(scaled))
        } catch {
            output.append(error, errorText: "An error occurred while creating a new image")
        }
	}
}
