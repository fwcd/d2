// The new commands argument API which uses generic composition
// of types to statically determine the "pattern" of arguments
// and can automatically generate usage examples.

/**
 * A (possibly composed) command argument.
 * 
 * There are two ways of instantiating an implementing argument type.
 * 
 * - As a _pattern_, enabling the generation of a usage description and examples
 * - As a _value_, allowing the use of the structured value itself
 */
public protocol Arg: CustomStringConvertible {
    /** Whether this instantiation is a _pattern instantiation_. */
    var isPattern: Bool { get }

    /**
     * Generates up to n usage examples.
     *
     * **This method should only be called if `isPattern` is true.**
     */
    func generateExamples(_ n: Int) -> [String]
}

/** A simple value argument. */
public struct ArgValue<T>: Arg {
    public let value: T
    public let isPattern: Bool
    public let examples: [String]
    public var description: String { return "[\(value)]" }

    /** Creates a _value instantiation_ of this argument. */
    public init(value: T) {
        isPattern = false
        self.value = value
        examples = []
    }
    
    public func generateExamples(_ n: Int) -> [String] {
        return Array(examples.prefix(n))
    }
}

extension ArgValue where T == String {
    /** Creates a _pattern instantiation_ of this argument. */
    public init(patternWithName name: String, examples: [String]) {
        isPattern = true
        value = "[\(name)]"
        self.examples = examples
    }
}

/** A concatenation of two arguments, i.e. a "product argument". */
public struct ArgPair<L, R>: Arg where L: Arg, R: Arg {
    public let left: L
    public let right: R
    public let isPattern: Bool
    public var description: String { return "\(left) \(right)" }
    
    public init(patternWithLeft left: L, right: R) {
        isPattern = true
        self.left = left
        self.right = right
    }

    /** Creates a value-instantiation of this argument. */
    public init(left: L, right: R) {
        isPattern = false
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

/** An alternation over two arguments, i.e. a "sum argument". */
public struct ArgEither<L, R>: Arg where L: Arg, R: Arg {
    public let left: L?
    public let right: R?
    public let isPattern: Bool
    public var description: String {
        let s = [left as Arg?, right as Arg?]
            .compactMap { $0 }
            .map { "\($0)" }
            .joined(separator: " | ")
        return "(\(s))"
    }
    
    /** Creates a _pattern instantiation_ of this argument. */
    public init(patternWithLeft left: L, right: R) {
        isPattern = true
        self.left = left
        self.right = right
    }
    
    /** Creates a _value instantiation_ of the left side. */
    public init(left: L) {
        isPattern = false
        self.left = left
        right = nil
    }
    
    /** Creates a _value instantiation_ of the right side. */
    public init(right: R) {
        isPattern = false
        left = nil
        self.right = right
    }
    
    public func generateExamples(_ n: Int) -> [String] {
        return (left!.generateExamples(n / 2) + right!.generateExamples(n / 2))
            .shuffled()
    }
}

/** An optional argument. */
public struct ArgOption<T>: Arg where T: Arg {
    public let value: T?
    public let isPattern: Bool
    public var description: String { return "\(value?.description ?? "nil")?" }
    
    /** Creates a _pattern instantiation_ of this argument. */
    public init(patternWithValue value: T) {
        isPattern = true
        self.value = value
    }
    
    /** Creates a _value instantiation_ of this argument. */
    public init(value: T?) {
        isPattern = false
        self.value = value
    }
    
    public func generateExamples(_ n: Int) -> [String] {
        return value!.generateExamples(n)
    }
}

/** A repetition of this argument, zero or more times. */
public struct ArgRepeat<T>: Arg where T: Arg {
    public let values: [T]
    public let isPattern: Bool
    public var description: String {
        if isPattern {
            return "\(values.first!)*"
        } else {
            return "\(values)"
        }
    }
    
    /** Creates a _pattern instantiation_ of this argument. */
    public init(patternWithValue value: T) {
        values = [value]
        isPattern = true
    }
    
    /** Creates a _value instantiation_ of this argument. */
    public init(values: [T]) {
        self.values = values
        isPattern = false
    }
    
    public func generateExamples(_ n: Int) -> [String] {
        return self.values.first!.generateExamples(n)
    }
}

/** A repetition of this argument, one or more times. */
public struct ArgRepeat1<T>: Arg where T: Arg {
    public let values: [T]
    public let isPattern: Bool
    public var description: String {
        if isPattern {
            return "\(values.first!)+"
        } else {
            return "\(values)"
        }
    }
    
    /** Creates a _pattern instantiation_ of this argument. */
    public init(patternWithValue value: T) {
        values = [value]
        isPattern = true
    }
    
    /** Creates a _value instantiation_ of this argument. */
    public init?(values: [T]) {
        if values.isEmpty {
            return nil
        }
        self.values = values
        isPattern = false
    }
    
    public func generateExamples(_ n: Int) -> [String] {
        return self.values.first!.generateExamples(n)
    }
}
