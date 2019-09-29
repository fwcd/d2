// The new commands argument API which uses generic composition
// of types to statically determine the "pattern" of arguments
// and can automatically generate usage examples.

/** A (possibly composed) command argument. */
public protocol Arg {
    /** Fetches the usage pattern. */
    var usage: String { get }

    /** Generates up to n usage examples. */
    func generateExamples(_ n: Int) -> [String]
}

/** A simple value argument. */
public struct ArgValue<T>: Arg {
    public let value: T
    public let examples: [String]
    public var usage: String { return "[\(value)]" }
    
    public init(value: T, examples: [String] = []) {
        self.value = value
        self.examples = examples
    }
    
    public func generateExamples(_ n: Int) -> [String] {
        return Array(examples.prefix(n))
    }
}

/** A pair of two arguments. */
public struct ArgPair<L, R>: Arg where L: Arg, R: Arg {
    public let left: L
    public let right: R
    public var usage: String { return "\(left.usage) \(right.usage)" }
    
    public init(left: L, right: R) {
        self.left = left
        self.right = right
    }
    
    public func generateExamples(_ n: Int) -> [String] {
        let leftExamples = left.generateExamples(n)
        let rightExamples = right.generateExamples(n)
        return Array(leftExamples
            .flatMap { l in rightExamples.map { r in "\(l) \(r)" } }
            .shuffled()
            .prefix(n))
    }
}
