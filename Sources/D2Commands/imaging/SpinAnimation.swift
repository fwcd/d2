import D2Graphics
import D2Utils

public struct SpinAnimation: Animation {
    public init() {}

    public func renderFrame(from image: Image, to graphics: inout Graphics, percent: Double, args: String) {
        let angle = percent * 2 * Double.pi
        graphics.draw(image, at: Vec2(x: 0, y: 0), rotation: angle)
    }
}
