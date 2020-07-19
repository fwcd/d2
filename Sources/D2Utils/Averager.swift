public struct Averager {
    private var value: Double = 0
    private var count: Int = 0

    public var average: Double? { count == 0 ? nil : value / Double(count) }

    public init() {}

    public mutating func insert<I>(_ value: I) where I: BinaryInteger {
        insert(Double(value))
    }

    public mutating func insert<F>(_ value: F) where F: BinaryFloatingPoint {
        self.value += Double(value)
        count += 1
    }
}
