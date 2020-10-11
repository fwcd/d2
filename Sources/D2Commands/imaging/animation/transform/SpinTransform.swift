import Graphics
import Utils

public struct SpinTransform: ImageTransform {
    public enum Key: String, StringEnum {
        case direction
    }

    private enum Direction: String {
        case clockwise
        case counterclockwise

        var sign: Int {
            switch self {
                case .clockwise: return -1
                case .counterclockwise: return 1
            }
        }
    }

    private let pos: Vec2<Int>?
    private let direction: Direction

    public init(at pos: Vec2<Int>?, kvArgs: [Key: String]) {
        self.pos = pos
        direction = kvArgs[.direction].flatMap(Direction.init(rawValue:)) ?? .counterclockwise
    }

    public func sourcePos(from destPos: Vec2<Int>, imageSize: Vec2<Int>, percent: Double) -> Vec2<Int> {
        let centerPos = pos ?? (imageSize / 2)
        return (Mat2<Double>.rotation(by: Double(direction.sign) * percent * 2.0 * .pi) * (destPos - centerPos).asDouble).floored + centerPos
    }
}
