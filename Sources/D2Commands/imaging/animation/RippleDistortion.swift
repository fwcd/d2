import Foundation

public struct RippleDistortion: RadialDistortion {
    public init() {}

    public func sourceDist(from normalizedDestDist: Double, percent: Double) -> Double {
        let x = normalizedDestDist
        return x + percent * x * sin(40 * x)
    }
}
