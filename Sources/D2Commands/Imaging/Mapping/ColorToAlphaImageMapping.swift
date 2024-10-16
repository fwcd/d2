@preconcurrency import CairoGraphics

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

    public func apply(to image: CairoImage) throws -> CairoImage {
        // TODO: Add a key-value argument that optionally specifies this
        // Tolerance is specified in squared [0, 1] RGB space
        return try colorToAlpha(in: image, color: color)
    }
}
