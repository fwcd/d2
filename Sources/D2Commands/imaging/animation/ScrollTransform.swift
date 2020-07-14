import D2Utils

public struct ScrollTransform: ImageTransform {
    public enum Key: String, StringEnum {
        case speed
        case direction
    }

    public enum Direction: String {
        case up
        case down
        case left
        case right

        public var asUnitVector: Vec2<Int> {
            switch self {
                case .up: return Vec2(x: 0, y: -1)
                case .down: return Vec2(x: 0, y: 1)
                case .left: return Vec2(x: 1, y: 0)
                case .right: return Vec2(x: -1, y: 0)
            }
        }
        public var horizontal: Bool {
            self == .left || self == .right
        }
    }

    private let pos: Vec2<Int>?
    private let speed: Int
    private let direction: Direction

    public init(at pos: Vec2<Int>?, kvArgs: [Key: String]) {
        self.pos = pos

        speed = kvArgs[.speed].flatMap(Int.init) ?? 1
        direction = kvArgs[.direction].flatMap(Direction.init(rawValue:)) ?? .right
    }
    
    public func sourcePos(from destPos: Vec2<Int>, imageSize: Vec2<Int>, percent: Double) -> Vec2<Int> {
        destPos + (direction.asUnitVector * speed * Int(Double(direction.horizontal ? imageSize.x : imageSize.y) * percent))
            .mapBoth({ ($0 + imageSize.x) % imageSize.x }, { ($0 + imageSize.y) % imageSize.y })
    }
}
