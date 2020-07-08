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

    private let maxWidth: Int
    private let maxHeight: Int

	public init(maxWidth: Int = 800, maxHeight: Int = 800) {
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
    }
	
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

            guard (0..<maxWidth).contains(width), (0..<maxHeight).contains(height) else {
                output.append(errorText: "Please ensure that your size is within the bounds of \(maxWidth), \(maxHeight)!")
                return
            }
            
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
