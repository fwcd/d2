import D2Graphics
import D2Utils

public struct TransformAnimation<T: ImageTransform>: Animation {
    private let transform: T
    
    public init(args: String) {
        transform = T.init(args: args)
    }

    public func renderFrame(from image: Image, to frame: inout Image, percent: Double) {
        let width = image.width
        let height = image.height

        for y in 0..<height {
            for x in 0..<width {
                let src = transform.sourcePos(from: Vec2(x: x, y: y), percent: percent)
                if src.x >= 0 && src.x < width && src.y >= 0 && src.y < height {
                    frame[y, x] = image[src.y, src.x]
                }
            }
        }
    }
}
