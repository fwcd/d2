import Graphics

public struct InvertImageMapping: ImageMapping {
    public init(args: String?) {}

    public func apply(to image: Image) throws -> Image {
        let width = image.width
        let height = image.height
        let inverted = try Image(width: width, height: height)

        for y in 0..<height {
            for x in 0..<width {
                inverted[y, x] = image[y, x].inverted
            }
        }

        return inverted
    }
}
