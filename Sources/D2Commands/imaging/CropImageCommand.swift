import D2Utils
import D2MessageIO
import D2Graphics

fileprivate let argsPattern = try! Regex(from: "(\\d+)\\s+(\\d+)\\s+(\\d+)\\s+(\\d+)")

public class CropImageCommand: Command {
	public let info = CommandInfo(
		category: .imaging,
		shortDescription: "Crops an image",
        helpText: "Syntax: [top left x] [top left y] [bottom right x] [bottom right y]",
		requiredPermissionLevel: .basic
	)
	public let inputValueType: RichValueType = .compound([.image, .text])
	public let outputValueType: RichValueType = .image

    public init() {}

	public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
		guard let img = input.asImage else {
			output.append(errorText: "Not an image!")
            return
        }

        guard let rawBounds = input.asText,
            let parsedBounds = argsPattern.firstGroups(in: rawBounds)?[1...].compactMap(Int.init) else {
            output.append(errorText: info.helpText!)
            return
        }

        let (topLeftX, topLeftY, bottomRightX, bottomRightY) = (parsedBounds[0], parsedBounds[1], parsedBounds[2], parsedBounds[3])

        let inputWidth = img.width
        let inputHeight = img.height

        guard (0..<inputHeight).contains(topLeftY), (0..<inputWidth).contains(topLeftX), (0..<inputHeight).contains(bottomRightY), (0..<inputWidth).contains(bottomRightX) else {
            output.append(errorText: "Make sure that all cropped bounds are in the image's bounds!")
            return
        }

        do {
            let width = bottomRightX - topLeftX
            let height = bottomRightY - topLeftY

            guard width > 0, height > 0 else {
                output.append(errorText: "Make sure that the width/height of the cropped dimensions are positive!")
                return
            }

            var cropped = try Image(width: width, height: height)

            for y in 0..<height {
                for x in 0..<width {
                    cropped[y, x] = img[y + topLeftY, x + topLeftX]
                }
            }

            output.append(.image(cropped))
        } catch {
            output.append(error, errorText: "An error occurred while creating a new image")
        }
	}
}
