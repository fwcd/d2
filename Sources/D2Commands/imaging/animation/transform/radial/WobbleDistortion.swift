import Foundation

public struct WobbleDistortion: RadialDistortion {
    public init() {}

    public func sourceDist(from normalizedDestDist: Double, percent: Double) -> Double {
        -normalizedDestDist / (1 - 10 * percent * normalizedDestDist)
    }
}
