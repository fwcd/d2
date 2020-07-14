/** An axis-aligned direction in the 2D-plane. */
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
    public var axis: Axis {
        horizontal ? .x : .y
    }
}
