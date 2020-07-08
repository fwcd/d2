import D2Utils

fileprivate let scaleParameter = "scale"

public struct RadialTransform<R>: ImageTransform where R: RadialDistortion {
    public static let kvParameters: [String] = [scaleParameter]

    private let pos: Vec2<Int>?
    private let scale: Double
    
    public init(at pos: Vec2<Int>?, kvArgs: [String: String]) {
        self.pos = pos
        scale = kvArgs[scaleParameter].flatMap { Double($0) } ?? 1
    }
    
    public func sourcePos(from destPos: Vec2<Int>, imageSize: Vec2<Int>, percent: Double) -> Vec2<Int> {
        let center = pos ?? (imageSize / 2)
        let delta = (destPos - center).asDouble
        let scaleFactor = scale / Double(imageSize.y)
        let normalizedDestDist = delta.magnitude * scaleFactor
        let normalizedSourceDist = max(-10000, min(10000, R.init().sourceDist(from: normalizedDestDist, percent: percent)))
        return center + (delta * normalizedSourceDist).floored
    }
}
