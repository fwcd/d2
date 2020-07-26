import D2Utils
import D2Graphics

public class FilterImageCommand<F: ImageFilter>: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Applies an image convolution filter",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let image = input.asImage else {
            output.append(errorText: "Not an image")
            return
        }

        do {
            let width = image.width
            let height = image.height
            var result = try Image(width: width, height: height)
            let filterMatrix = F.init().matrix
            let halfMatrixWidth = filterMatrix.width / 2
            let halfMatrixHeight = filterMatrix.height / 2
            
            // Perform the convolution
            for y in 0..<height {
                for x in 0..<width {
                    var value: Color = Colors.transparent
                    for dy in 0..<filterMatrix.height {
                        for dx in 0..<filterMatrix.width {
                            let pixel = image[
                                max(0, min(height - 1, y + dy - halfMatrixHeight)),
                                max(0, min(width - 1, x + dx - halfMatrixWidth))
                            ]
                            let factor = filterMatrix[dy, dx]
                            value = pixel.mapAllChannels { UInt8(max(0, min(255, Double($0) * factor))) }.alphaBlend(over: value)
                        }
                    }
                    result[y, x] = value
                }
            }

            try output.append(result)
        } catch {
            output.append(error, errorText: "Error while processing image")
        }
    }
}
