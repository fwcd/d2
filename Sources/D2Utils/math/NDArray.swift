/// A multidimensional, rectangular, numeric array.
/// Generalization of a matrix/vector/scalar and
/// sometimes referred to as 'tensor'.
public struct NDArray<T: IntExpressibleAlgebraicField>: Addable, Subtractable, Hashable, CustomStringConvertible {
    public var values: [T] {
        didSet { assert(shape.reduce(1, *) == values.count) }
    }
    public var shape: [Int] {
        didSet { assert(shape.reduce(1, *) == values.count) }
    }

    public var dimension: Int { shape.count }
    public var description: String { generateDescription(coords: []) }

    public var asScalar: T? { dimension == 0 ? values[0] : nil }

    /// Creates an nd-array from a scalar.
    public init(_ value: T) {
        values = [value]
        shape = []
    }

    /// Creates an nd-array from a vector.
    public init(_ values: [T]) {
        self.values = values
        shape = [values.count]
    }

    /// Creates an nd-array from a matrix.
    public init(_ values: [[T]]) throws {
        // Ensure the matrix is rectangular
        var width: Int? = nil
        for row in values {
            if let w = width, w != row.count {
                throw NDArrayError.shapeMismatch("Cannot create NDArray from non-rectangular matrix")
            }
            width = row.count
        }

        guard let w = width else { throw NDArrayError.shapeMismatch("Cannot create zero-width matrix") }
        self.values = values.flatMap { $0 }
        shape = [values.count, w]
    }

    /// Creates an nd-array from the given nd-arrays.
    public init(ndArrays: [NDArray<T>]) throws {
        // Ensure the arrays have the same shape
        var innerShape: [Int]? = nil
        for ndArray in ndArrays {
            if let s = innerShape, s != ndArray.shape {
                throw NDArrayError.shapeMismatch("Cannot create NDArray from differently sized NDArrays")
            }
            innerShape = ndArray.shape
        }

        guard let shape = innerShape.map({ [ndArrays.count] + $0 }) else {
            throw NDArrayError.shapeMismatch("Cannot create a non-scalar NDArray with zero elements along one axis")
        }

        values = ndArrays.flatMap { $0.values }
        self.shape = shape
    }

    /// Creates an nd-array with a given shape.
    public init(_ values: [T], shape: [Int]) throws {
        guard shape.reduce(1, *) == values.count else {
            throw NDArrayError.shapeMismatch("Shape \(shape) does not match value count \(values.count)")
        }
        self.values = values
        self.shape = shape
    }

    private func generateDescription(coords: [Int]) -> String {
        if coords.count == dimension {
            return "\(self[coords])"
        } else {
            return "(\((0..<shape[coords.count]).map { generateDescription(coords: coords + [$0]) }.joined(separator: ", ")))"
        }
    }

    public subscript(_ coords: [Int]) -> T {
        get { values[index(of: coords)] }
        set { values[index(of: coords)] = newValue }
    }

    private func index(of coords: [Int]) -> Int {
        var i = 0
        var stride = 1
        for j in (0..<coords.count).reversed() {
            i += coords[j] * stride
            stride *= shape[j]
        }
        return i
    }

    public func map<U>(_ f: (T) -> U) -> NDArray<U> where U: IntExpressibleAlgebraicField {
        try! NDArray<U>(values.map(f), shape: shape)
    }
    
    public func zip<U>(_ rhs: NDArray<T>, with f: (T, T) -> U) throws -> NDArray<U> where U: IntExpressibleAlgebraicField {
        guard shape == rhs.shape else {
            throw NDArrayError.shapeMismatch("Cannot zip two differently shaped NDArrays: \(shape), \(rhs.shape)")
        }
        var zipped = [U](repeating: 0, count: values.count)
        for i in 0..<zipped.count {
            zipped[i] = f(values[i], rhs.values[i])
        }
        return try! NDArray<U>(zipped, shape: shape)
    }

    public static func +(lhs: Self, rhs: Self) -> Self {
        try! lhs.zip(rhs, with: +)
    }

    public static func -(lhs: Self, rhs: Self) -> Self {
        try! lhs.zip(rhs, with: -)
    }

    public static func *(lhs: Self, rhs: T) -> Self {
        lhs.map { $0 * rhs }
    }

    public static func /(lhs: Self, rhs: T) -> Self {
        lhs.map { $0 / rhs }
    }

    public static func *(lhs: T, rhs: Self) -> Self {
        rhs.map { lhs * $0 }
    }
}