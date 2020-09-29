import D2MessageIO
import Graphics

public class ColorToAlphaCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Converts a color to transparency",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .image
    public let outputValueType: RichValueType = .image

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let rawColor = input.asText,
            let colorRGB = UInt32(rawColor, radix: 16) else {
            output.append(errorText: "Please specify an RGB color (to be converted to alpha) in hex notation!")
            return
        }

        let color = Color(rgb: colorRGB)

        // TODO: Add a key-value argument that optionally specifies this
        // Tolerance is specified in squared [0, 1] RGB space
        let tolerance = 0.1

        if let image = input.asImage {
            do {
                let width = image.width
                let height = image.height
                var processed = try Image(width: width, height: height)

                for y in 0..<height {
                    for x in 0..<width {
                        let inColor = image[y, x]
                        let outColor: Color

                        if inColor.euclideanDistance(to: color, useAlpha: false) < tolerance {
                            outColor = Colors.transparent
                        } else {
                            outColor = inColor
                        }

                        processed[y, x] = outColor
                    }
                }

                output.append(.image(processed))
            } catch {
                output.append(error, errorText: "An error occurred while creating a new image")
            }
        } else {
            output.append(errorText: "Not an image!")
        }
    }
}
