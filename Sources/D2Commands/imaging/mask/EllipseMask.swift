import D2Utils

public struct EllipseMask: ImageMask {
    public init() {}

    public func contains(pos: Vec2<Int>, imageSize: Vec2<Int>) -> Bool {
        let unitCirclePos = Vec2<Double>(x: (Double(pos.x) / Double(imageSize.x)) - 0.5, y: (Double(pos.y) / Double(imageSize.y)) - 0.5)
        return unitCirclePos.squaredMagnitude <= 0.25
    }
}
