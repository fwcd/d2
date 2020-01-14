import Foundation

public struct WarpDistortion: RadialDistortion {
    public init() {}
    
    public func sourceDist(from normalizedDestDist: Double, percent: Double) -> Double {
        -log(normalizedDestDist * percent + 0.1)
    }
}
