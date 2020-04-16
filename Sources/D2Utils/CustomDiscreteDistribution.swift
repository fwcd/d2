public struct CustomDiscreteDistribution<T>: Distribution {
    private let distribution: [(T, Double)]
    
    public init(_ distribution: [(T, Double)]) {
        // Assert that the probabilities add up to one
        assert(abs(1 - distribution.map { $0.1 }.reduce(0, +)) < 0.0001)
        self.distribution = distribution
    }

    public func sample() -> T {
        var x = Double.random(in: 0.0..<1.0)

        for (value, probability) in distribution {
            x -= probability
            if x < 0 {
                return value
            }
        }
        
        return distribution.last!.0
    }
}
