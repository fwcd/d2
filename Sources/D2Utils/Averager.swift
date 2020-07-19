/**
 * Collects useful statistics on the fly with constant
 * memory consumption.
 */
public struct Averager {
    private var value: Double = 0
    private var count: Int = 0

    public private(set) var minimum: Double? = nil
    public private(set) var maximum: Double? = nil
    public var average: Double? { count == 0 ? nil : value / Double(count) }

    public init() {}

    public mutating func insert<I>(_ value: I) where I: BinaryInteger {
        insert(Double(value))
    }

    public mutating func insert<F>(_ value: F) where F: BinaryFloatingPoint {
        self.value += Double(value)
        minimum = min(minimum ?? .infinity, Double(value))
        maximum = max(maximum ?? -.infinity, Double(value))
        count += 1
    }
}
