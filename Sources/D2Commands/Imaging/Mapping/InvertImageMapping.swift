import CairoGraphics

public struct InvertImageMapping: ImageMapping {
    public init(args: String?) {}

    public func apply(to image: CairoImage) throws -> CairoImage {
        let width = image.width
        let height = image.height
        let inverted = try CairoImage(width: width, height: height)

        for y in 0..<height {
            for x in 0..<width {
                inverted[y, x] = image[y, x].inverted
            }
        }

        return inverted
    }
}
