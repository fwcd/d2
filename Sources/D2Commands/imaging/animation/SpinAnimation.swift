import D2Graphics
import D2Utils

public struct SpinAnimation: Animation {
    public init() {}

    public func renderFrame(from image: Image, to frame: inout Image, percent: Double, args: String) {
        var graphics = CairoGraphics(fromImage: frame)
        let angle = percent * 2 * Double.pi
        graphics.draw(image, at: Vec2(x: 0, y: 0), rotation: angle)
    }
}
