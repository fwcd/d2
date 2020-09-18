import D2Utils

public struct RadialTransform<R>: ImageTransform where R: RadialDistortion {
    public enum Key: String, StringEnum {
        case scale
    }

    private let pos: Vec2<Int>?
    private let scale: Double

    public init(at pos: Vec2<Int>?, kvArgs: [Key: String]) {
        self.pos = pos
        scale = kvArgs[.scale].flatMap { Double($0) } ?? 1
    }

    public func sourcePos(from destPos: Vec2<Int>, imageSize: Vec2<Int>, percent: Double) -> Vec2<Int> {
        let center = pos ?? (imageSize / 2)
        let intDelta = destPos - center
        guard intDelta != .zero() else { return center }
        let delta = intDelta.asDouble
        let scaleFactor = scale / Double(imageSize.y)
        let normalizedDestDist = delta.magnitude * scaleFactor
        let normalizedSourceDist = max(-10000, min(10000, R.init().sourceDist(from: normalizedDestDist, percent: percent)))
        return center + (delta.normalized * normalizedSourceDist * Double(imageSize.y)).floored
    }
}
