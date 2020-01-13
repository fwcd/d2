import D2Utils

public struct TwirlTransform: ImageTransform {
    private let pos: Vec2<Int>?

    public init(at pos: Vec2<Int>?) {
        self.pos = pos
    }
    
    public func sourcePos(from destPos: Vec2<Int>, imageSize: Vec2<Int>, percent: Double) -> Vec2<Int> {
        let center = pos ?? (imageSize / 2)
        let delta = (destPos - center).asDouble
        let normalizedDist = delta.magnitude / Double(imageSize.y)
        return center + (Mat2<Double>.rotation(by: 2 * Double.pi * normalizedDist * percent) * delta).floored
    }
}
