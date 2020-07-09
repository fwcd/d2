public struct WobbleDistortion: RadialDistortion {
    public init() {}

    public func sourceDist(from normalizedDestDist: Double, percent: Double) -> Double {
        -1 / (1 + -percent * normalizedDestDist)
    }
}
