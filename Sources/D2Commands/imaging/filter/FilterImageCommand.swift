import D2Utils
import D2Graphics

public class FilterImageCommand<F: ImageFilter>: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Applies an image convolution filter",
        requiredPermissionLevel: .basic
    )
    private let maxSize: Int

    public init(maxSize: Int = 15) {
        self.maxSize = maxSize
    }

    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let image = input.asImage else {
            output.append(errorText: "Not an image")
            return
        }

        guard let size = input.asText.map(Int.init) ?? 5 else {
            output.append(errorText: "Please provide an integer for specifying the filter size!")
            return
        }

        guard size <= maxSize else {
            output.append(errorText: "Please use a filter size smaller or equal to \(maxSize)!")
            return
        }

        do {
            let width = image.width
            let height = image.height
            var result = try Image(width: width, height: height)
            let filterMatrix = F.init(size: size).matrix
            let halfMatrixWidth = filterMatrix.width / 2
            let halfMatrixHeight = filterMatrix.height / 2

            let pixels = (0..<height).map { y in (0..<width).map { x in image[y, x] } }

            func clampToByte(_ value: Double) -> UInt8 {
                UInt8(max(0, min(255, value)))
            }

            // Perform the convolution
            for y in 0..<height {
                for x in 0..<width {
                    var value: (red: Double, green: Double, blue: Double, alpha: Double) = (red: 0, green: 0, blue: 0, alpha: 0)
                    for dy in 0..<filterMatrix.height {
                        for dx in 0..<filterMatrix.width {
                            let pixel = pixels[max(0, min(height - 1, y + dy - halfMatrixHeight))][max(0, min(width - 1, x + dx - halfMatrixWidth))]
                            let factor = filterMatrix[dy, dx]

                            value = (
                                red: value.red + Double(pixel.red) * factor,
                                green: value.green + Double(pixel.green) * factor,
                                blue: value.blue + Double(pixel.blue) * factor,
                                alpha: value.alpha + Double(pixel.alpha) * factor
                            )
                        }
                    }
                    result[y, x] = Color(
                        red: clampToByte(value.red),
                        green: clampToByte(value.green),
                        blue: clampToByte(value.blue),
                        alpha: max(pixels[y][x].alpha, clampToByte(value.alpha))
                    )
                }
            }

            try output.append(result)
        } catch {
            output.append(error, errorText: "Error while processing image")
        }
    }
}
