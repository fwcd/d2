import D2Utils

public struct SlideTransform: ImageTransform {
    public enum Key: String, StringEnum {
        case speed
        case direction
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
        (destPos - (direction.asUnitVector * speed * Int(Double(direction.horizontal ? imageSize.x : imageSize.y) * percent)))
            .mapBoth({ $0 %% imageSize.x }, { $0 %% imageSize.y })
    }
}
