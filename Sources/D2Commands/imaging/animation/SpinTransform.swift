import D2Graphics
import D2Utils

public struct SpinTransform: ImageTransform {
    public enum Key: String, StringEnum {
        case speed
    }

    private let pos: Vec2<Int>?
    private let speed: Double

    public init(at pos: Vec2<Int>?, kvArgs: [Key: String]) {
        self.pos = pos
        speed = kvArgs[.speed].flatMap(Double.init) ?? 1
    }

    public func sourcePos(from destPos: Vec2<Int>, imageSize: Vec2<Int>, percent: Double) -> Vec2<Int> {
        let centerPos = imageSize / 2
        return (Mat2<Double>.rotation(by: speed * percent * 2.0 * .pi) * (destPos - centerPos).asDouble).floored + centerPos
    }
}
