import Graphics
import Utils

public struct SpinTransform: ImageTransform {
    public enum Key: String, StringEnum {
        case speed
    }

    private let pos: Vec2<Int>?

    public init(at pos: Vec2<Int>?, kvArgs: [Key: String]) {
        self.pos = pos
    }

    public func sourcePos(from destPos: Vec2<Int>, imageSize: Vec2<Int>, percent: Double) -> Vec2<Int> {
        let centerPos = imageSize / 2
        return (Mat2<Double>.rotation(by: percent * 2.0 * .pi) * (destPos - centerPos).asDouble).floored + centerPos
    }
}
