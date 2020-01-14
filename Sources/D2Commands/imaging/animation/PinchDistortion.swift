import Foundation

public struct PinchDistortion: RadialDistortion {
    public init() {}
    
    public func sourceDist(from normalizedDestDist: Double, percent: Double) -> Double {
        let x = normalizedDestDist * percent
        return x.squareRoot()
    }
}
