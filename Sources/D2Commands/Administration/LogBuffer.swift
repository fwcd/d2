import Utils

/// A cyclic buffer for log messages.
public actor LogBuffer {
    public private(set) var lastOutputs: CircularArray<String>

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
}
