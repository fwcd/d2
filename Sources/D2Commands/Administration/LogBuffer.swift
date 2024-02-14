import Utils

/// A cyclic buffer for log messages.
public class LogBuffer: Sequence {
    private var lastOutputs: CircularArray<String>

    public var count: Int { lastOutputs.count }

    public init(capacity: Int = 100) {
        lastOutputs = CircularArray(capacity: capacity)
    }

    public func push(_ message: String) {
        lastOutputs.push(message)
    }

    public func suffix(_ n: Int) -> [String] {
        lastOutputs.suffix(n)
    }

    public func makeIterator() -> CircularArray<String>.Iterator {
        lastOutputs.makeIterator()
    }
}
