// The new commands argument API which uses generic composition
// of types to statically determine the "pattern" of arguments
// and can automatically generate usage examples.

import D2Utils

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
    * Fetches the maximum number of tokens that this arg can parse.
    *
    * **This property should only be fetches if `isPattern` is true.**
    */
    var maxTokens: Int { get }

    /**
    * Parses the argument structure from a token iterator
    * of space-delimited words.
    *
    * The iterator should be considered
    * "consumed" if this method returns `nil`.
    */
    static func parse(from tokens: TokenIterator<String>) -> Self?

    /**
    * Generates up to n usage examples.
    *
    * **This method should only be called if `isPattern` is true.**
    */
    func generateExamples(_ n: Int) -> [String]
}

/** A simple value argument. */
public struct ArgValue<T>: Arg where T: LosslessStringConvertible {
    public let value: T
    public let isPattern: Bool
    public let examples: [String]
    public let maxTokens: Int = 1
    public var description: String { return "[\(value)]" }

    /** Creates a _value instantiation_ of this argument. */
    public init(value: T) {
        isPattern = false
        self.value = value
        examples = []
    }

    /** Creates a _pattern instantiation_ of this argument. */
    public init(name: T, examples: [String]) {
        isPattern = true
        value = name
        self.examples = examples
    }

    public static func parse(from tokens: TokenIterator<String>) -> ArgValue<T>? {
        guard let token = tokens.peek() else { return nil }
        guard let parsed = T.init(token) else { return nil }
        tokens.next()
        return ArgValue.init(value: parsed)
    }

    public func generateExamples(_ n: Int) -> [String] {
        return Array(examples.prefix(n))
    }
}

/** A concatenation of two arguments, i.e. a "product argument". */
public struct ArgPair<L, R>: Arg where L: Arg, R: Arg {
    public let left: L
    public let right: R
    public let isPattern: Bool
    public var maxTokens: Int { return max(left.maxTokens, right.maxTokens) }
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

    public static func parse(from tokens: TokenIterator<String>) -> ArgPair<L, R>? {
        guard let left = L.parse(from: tokens) else { return nil }
        guard let right = R.parse(from: tokens) else { return nil }
        return ArgPair.init(left: left, right: right)
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
// public struct ArgEither<L, R>: Arg where L: Arg, R: Arg {
//     public let left: L?
//     public let right: R?
//     public let isPattern: Bool
//     public var description: String {
//         let s = [left as Arg?, right as Arg?]
//             .compactMap { $0 }
//             .map { "\($0)" }
//             .joined(separator: " | ")
//         return "(\(s))"
//     }

//     /** Creates a _pattern instantiation_ of this argument. */
//     public init(patternWithLeft left: L, right: R) {
//         isPattern = true
//         self.left = left
//         self.right = right
//     }

//     /** Creates a _value instantiation_ of the left side. */
//     public init(left: L) {
//         isPattern = false
//         self.left = left
//         right = nil
//     }

//     /** Creates a _value instantiation_ of the right side. */
//     public init(right: R) {
//         isPattern = false
//         left = nil
//         self.right = right
//     }

//     public static func parse(from tokens: TokenIterator<String>) -> ArgEither<L, R>? {
//         TODO
//     }

//     public func generateExamples(_ n: Int) -> [String] {
//         return (left!.generateExamples(n / 2) + right!.generateExamples(n / 2))
//             .shuffled()
//     }
// }

/** An optional argument. */
public struct ArgOption<T>: Arg where T: Arg {
    public let value: T?
    public let isPattern: Bool
    public var maxTokens: Int { return value!.maxTokens }
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

    public static func parse(from tokens: TokenIterator<String>) -> ArgOption<T>? {
        return ArgOption.init(value: T.parse(from: tokens))
    }

    public func generateExamples(_ n: Int) -> [String] {
        return value!.generateExamples(n)
    }
}

/** A repetition of this argument, zero or more times. */
public struct ArgRepeat<T>: Arg where T: Arg {
    public let values: [T]
    public let isPattern: Bool
    public let maxTokens: Int = Int.max
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

    public static func parse(from tokens: TokenIterator<String>) -> ArgRepeat<T>? {
        var values = [T]()
        while let token = T.parse(from: tokens) {
            values.append(token)
        }
        return ArgRepeat.init(values: values)
    }

    public func generateExamples(_ n: Int) -> [String] {
        return self.values.first!.generateExamples(n)
    }
}

/** A repetition of this argument, one or more times. */
public struct ArgRepeat1<T>: Arg where T: Arg {
    public let values: [T]
    public let isPattern: Bool
    public let maxTokens: Int = Int.max
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

    public static func parse(from tokens: TokenIterator<String>) -> ArgRepeat1<T>? {
        guard let firstToken = T.parse(from: tokens) else { return nil }
        var values = [firstToken]
        while let token = T.parse(from: tokens) {
            values.append(token)
        }
        return ArgRepeat1.init(values: values)
    }

    public func generateExamples(_ n: Int) -> [String] {
        return self.values.first!.generateExamples(n)
    }
}
