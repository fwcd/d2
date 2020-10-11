import D2MessageIO
import Graphics

public struct ColorToAlphaImageMapping: ImageMapping {
    private let color: Color

    private enum ColorToAlphaError: Error {
        case invalidArgs(String)
    }

    public init(args: String?) throws {
        guard
            let rawColor = args,
            let colorRGB = UInt32(rawColor, radix: 16) else {
            throw ColorToAlphaError.invalidArgs("Please specify an RGB color (to be converted to alpha) in hex notation!")
        }

        color = Color(rgb: colorRGB)
    }

    public func apply(to image: Image) throws -> Image {
        // TODO: Add a key-value argument that optionally specifies this
        // Tolerance is specified in squared [0, 1] RGB space
        let tolerance = 0.1

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

        return processed
    }
}
