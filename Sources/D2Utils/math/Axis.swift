/** An axis in the 2D-plane. */
public enum Axis: String {
    case x
    case y

    public var asUnitVector: Vec2<Int> {
        switch self {
            case .x: return Vec2(x: 1, y: 0)
            case .y: return Vec2(x: 0, y: 1)
        }
    }
}
