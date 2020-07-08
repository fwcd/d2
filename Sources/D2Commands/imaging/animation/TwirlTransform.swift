import D2Utils

fileprivate let scaleParameter = "scale"
fileprivate let rotationBiasParameter = "rotationBias"
fileprivate let rotationStrengthParameter = "rotationStrength"

public struct TwirlTransform: ImageTransform {
    public static let kvParameters: [String] = [scaleParameter, rotationBiasParameter, rotationStrengthParameter]

    private let pos: Vec2<Int>?
    private let scale: Double
    private let rotationBias: Double
    private let rotationStrength: Double

    public init(at pos: Vec2<Int>?, kvArgs: [String: String]) {
        self.pos = pos
        scale = kvArgs["scale"].flatMap { Double($0) } ?? 1
        rotationBias = kvArgs["rotationBias"].flatMap { Double($0) } ?? 0
        rotationStrength = kvArgs["rotationStrength"].flatMap { Double($0) } ?? 1
    }
    
    public func sourcePos(from destPos: Vec2<Int>, imageSize: Vec2<Int>, percent: Double) -> Vec2<Int> {
        let center = pos ?? (imageSize / 2)
        let delta = (destPos - center).asDouble
        let normalizedDist = (delta.magnitude * scale) / Double(imageSize.y)
        let angle = 2 * Double.pi * (normalizedDist * rotationStrength + rotationBias) * percent
        return center + (Mat2<Double>.rotation(by: angle) * delta).floored
    }
}
