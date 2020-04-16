/// A discrete probability distribution created from
/// custom values.
public struct CustomDiscreteDistribution<T>: Distribution {
    private let distribution: [(T, Double)]
    
    /// Creates a probability distribution that normalizes the given
    /// probabilities to the unit interval.
    public init<N>(normalizing distribution: [(T, N)]) where N: BinaryInteger {
        let sum = Double(distribution.map { $0.1 }.reduce(0, +))
        self.init(distribution.map { ($0.0, Double($0.1) / sum) })
    }
    
    public init(_ distribution: [(T, Double)]) {
        // Assert that the probabilities add up to one
        assert(!distribution.isEmpty)
        assert(abs(1 - distribution.map { $0.1 }.reduce(0, +)) < 0.001)
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
