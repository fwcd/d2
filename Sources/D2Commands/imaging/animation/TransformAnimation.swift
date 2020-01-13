import D2Graphics
import D2Utils

public struct TransformAnimation: Animation {
    private let transform: (Vec2<Int>, Double) -> Vec2<Int>

    public init(_ transform: @escaping (Vec2<Int>, Double) -> Vec2<Int>) {
        self.transform = transform
    }
    
    public func renderFrame(from image: Image, to frame: inout Image, percent: Double, args: String) {
        let width = image.width
        let height = image.height

        for y in 0..<height {
            for x in 0..<width {
                let dest = transform(Vec2(x: x, y: y), percent)
                frame[dest.y, dest.x] = image[y, x]
            }
        }
    }
}
