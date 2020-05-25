/// A multidimensional, rectangular, numeric array.
/// Generalization of a matrix/vector/scalar and
/// sometimes referred to as 'tensor'.
public struct NDArray<T: IntExpressibleAlgebraicField>: Addable, Subtractable, Hashable, CustomStringConvertible {
    private var values: [T]
    private var shape: [Int]

    public var dimension: Int { shape.count }
    public var description: String { generateDescription(coords: []) }

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
    public init(_ values: [[T]]) {
        // Ensure the matrix is rectangular
        var width: Int? = nil
        for row in values {
            if let w = width {
                assert(w == row.count, "Cannot create NDArray from non-rectangular matrix")
            }
            width = row.count
        }

        self.values = values.flatMap { $0 }
        shape = [values.count, values.isEmpty ? 0 : values[0].count]
    }

    /// Creates an nd-array with a given shape.
    public init(_ values: [T], shape: [Int]) {
        assert(shape.reduce(1, *) == values.count)
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
        NDArray<U>(values.map(f), shape: shape)
    }
    
    public func zip<U>(_ rhs: NDArray<T>, with f: (T, T) -> U) -> NDArray<U> where U: IntExpressibleAlgebraicField {
        assert(shape == rhs.shape)
        var zipped = [U](repeating: 0, count: values.count)
        for i in 0..<zipped.count {
            zipped[i] = f(values[i], rhs.values[i])
        }
        return NDArray<U>(zipped, shape: shape)
    }

    public static func +(lhs: Self, rhs: Self) -> Self {
        lhs.zip(rhs, with: +)
    }

    public static func -(lhs: Self, rhs: Self) -> Self {
        lhs.zip(rhs, with: -)
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