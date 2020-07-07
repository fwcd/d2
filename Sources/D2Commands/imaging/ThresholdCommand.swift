import D2MessageIO
import D2Permissions
import D2Graphics

public class ThresholdCommand: Command {
	public let info = CommandInfo(
		category: .imaging,
		shortDescription: "Thresholds an image",
		longDescription: "Produces a black/white image with a specified luminance threshold",
		requiredPermissionLevel: .basic
	)
	public let inputValueType: RichValueType = .compound([.image, .text])
	public let outputValueType: RichValueType = .image

    private let minThreshold: UInt8 = 0
    private let maxThreshold: UInt8 = 255
	
	public init() {}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		guard let img = input.asImage else {
			output.append(errorText: "Not an image!")
            return
        }

        guard let rawThreshold = input.asText,
            let threshold = UInt8(rawThreshold),
            threshold >= minThreshold,
            threshold <= maxThreshold else {
            output.append(errorText: "Please enter a threshold between \(minThreshold) and \(maxThreshold) (inclusive)!")
            return
        }

        do {
            let width = img.width
            let height = img.height
            var thresholded = try Image(width: width, height: height)
            
            for y in 0..<height {
                for x in 0..<width {
                    thresholded[y, x] = img[y, x].luminance > threshold
                        ? Colors.white
                        : Colors.black
                }
            }
            
            output.append(.image(thresholded))
        } catch {
            output.append(error, errorText: "An error occurred while creating a new image")
        }
	}
}
