import Graphics
import Utils

public struct MaskImageMapping<M>: ImageMapping where M: ImageMask {
    public init(args: String?) {
        // Do nothing
    }

    public func apply(to image: Image) throws -> Image {
        let width = image.width
        let height = image.height
        let mask = M.init()
        let masked = try Image(width: width, height: height)

        for y in 0..<height {
            for x in 0..<width {
                masked[y, x] = mask.contains(pos: Vec2(x: x, y: y), imageSize: Vec2(x: width, y: height))
                    ? image[y, x]
                    : Colors.transparent
            }
        }

        return masked
    }
}
