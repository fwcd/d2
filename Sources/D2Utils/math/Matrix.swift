import Foundation

fileprivate let epsilon = 0.00001

public struct Matrix<T: IntExpressibleAlgebraicField>: Addable, Subtractable, Hashable, CustomStringConvertible {
    public let width: Int
    public let height: Int
    private var values: [T]

    public var isSquare: Bool { width == height }

    public var rows: [[T]] { (0..<height).map { Array(self[row: $0]) } }
    public var columns: [[T]] { (0..<width).map { Array(self[column: $0]) } }
    public var rowVectors: [Vector<T>] { rows.map(Vector.init) }
    public var columnVectors: [Vector<T>] { columns.map(Vector.init) }
    public var asArray: [[T]] { rows }
    public var asNDArray: NDArray<T> { try! NDArray(values, shape: [height, width]) }

    public var description: String { "(\((0..<height).map { "(\(self[row: $0].map { "\($0)" }.joined(separator: ", ")))" }.joined(separator: ", ")))" }
    public var formattedDescription: String {
        (0..<height)
            .map { "(\(self[row: $0].map { "\($0)" }.joined(separator: ", ")))" }
            .joined(separator: "\n")
    }

    /// Computes the determinant in O(n!).
    public var laplaceExpansionDeterminant: T? {
        guard isSquare else { return nil }
        guard height > 1 else { return values[0] }
        return (0..<width).map { ($0 % 2 == 0 ? 1 : -1) * self[0, $0] * minor(0, $0).laplaceExpansionDeterminant! }.reduce(0, +)
    }
    /// Computes a triangular matrix from this matrix through Gauss elimination.
    public var rowEcholonForm: Matrix<T>? {
        var rowEcholon = self
        for x in 0..<(width - 1) {
            for y in (x + 1)..<height {
                let denom = rowEcholon[x, x]
                guard denom.absolute > epsilon else { return nil }
                rowEcholon.add(row: x, toRow: y, scaledBy: -rowEcholon[y, x] / denom)
            }
        }
        return rowEcholon
    }
    /// The row echolon form where all leading coefficients are 1.
    public var normalizedRowEcholonForm: Matrix<T>? {
        guard var rowEcholon = rowEcholonForm else { return nil }
        for y in 0..<height {
            rowEcholon.scale(row: y, by: 1 / rowEcholon.leadingCoefficient(y))
        }
        return rowEcholon
    }
    /// Finds the inverse of this matrix.
    public var inverse: Matrix<T>? {
        guard isSquare else { return nil }
        var rowEcholon = self
        var inv = Matrix<T>.identity(width: width)
        for x in 0..<(width - 1) {
            for y in (x + 1)..<height {
                let factor = -rowEcholon[y, x] / rowEcholon[x, x]
                inv.add(row: x, toRow: y, scaledBy: factor)
                rowEcholon.add(row: x, toRow: y, scaledBy: factor)
            }
        }
        for y in 0..<height {
            let coeff = rowEcholon.leadingCoefficient(y)
            guard coeff.absolute > epsilon else { return nil }
            inv.scale(row: y, by: 1 / coeff)
            rowEcholon.scale(row: y, by: 1 / coeff)
        }
        for x in (1..<width).reversed() {
            for y in (0..<x).reversed() {
                inv.add(row: x, toRow: y, scaledBy: -rowEcholon[y, x])
                // rowEcholon.add(row: x, toRow: y, scaledBy: -rowEcholon[y, x])
            }
        }
        return inv
    }
    public var mainDiagonal: [T]? {
        guard isSquare else { return nil }
        return (0..<width).map { self[$0, $0] }
    }

    /// Computes the determinant using Gaussian elimination in O(n^3).
    ///
    /// Note that this requires T to support precise division, i.e.
    /// to be of a floating point or rational type.
    /// If floating point values are not desired, use laplaceExpansionDeterminant
    /// instead (which has worse asymptotic time complexity though).
    public var determinant: T? {
        guard isSquare else { return nil }
        return rowEcholonForm?.mainDiagonal?.reduce(1, *) ?? 0
    }

    public var transpose: Matrix<T> {
        var t = Matrix(width: height, height: width, values: Array(repeating: 0, count: width * height))
        for y in 0..<height {
            for x in 0..<width {
                t[x, y] = self[y, x]
            }
        }
        return t
    }

    public init(width: Int, height: Int, values: [T]) {
        assert(values.count == (width * height))
        self.width = width
        self.height = height
        self.values = values
    }

    public init(repeating value: T, width: Int, height: Int) {
        self.width = width
        self.height = height
        values = Array(repeating: value, count: width * height)
    }

    public init(columnVector values: [T]) {
        width = 1
        height = values.count
        self.values = values
    }

    public init(rowVector values: [T]) {
        width = values.count
        height = 1
        self.values = values
    }

    public init(_ rows: [[T]]) {
        height = rows.count
        width = rows.first?.count ?? 0
        self.values = rows.flatMap { $0 }
    }

    public subscript(_ x: Int, _ y: Int) -> T {
        get { values[y + x * width] }
        set { values[y + x * width] = newValue }
    }

    public subscript(row y: Int) -> Row {
        Row(matrix: self, y: y)
    }

    public subscript(column x: Int) -> Column {
        Column(matrix: self, x: x)
    }

    public static func zero(width: Int, height: Int) -> Matrix<T> {
        Matrix(width: width, height: height, values: [T](repeating: 0, count: width * height))
    }

    public static func identity(width: Int) -> Matrix<T> {
        var values = [T](repeating: 0, count: width * width)
        for i in 0..<width {
            values[i * (width + 1)] = 1
        }
        return Matrix(width: width, height: width, values: values)
    }

    public static func diagonal(_ diagonalValues: [T]) -> Matrix<T> {
        let width = diagonalValues.count
        var values = [T](repeating: 0, count: width * width)
        for (i, diagonalValue) in diagonalValues.enumerated() {
            values[(i + 1) * width] = diagonalValue
        }
        return Matrix(width: width, height: width, values: values)
    }

    public func minor(_ y: Int, _ x: Int) -> Matrix<T> {
        Matrix(width: width - 1, height: height - 1, values: values.enumerated().compactMap { (i, v) in
            (i / width == y || i % width == x) ? nil : v
        })
    }

    public func leadingCoefficient(_ y: Int) -> T {
        for x in 0..<width {
            let coeff = self[y, x]
            if coeff.absolute > epsilon {
                return coeff
            }
        }
        return 0
    }

    public func reshaped(width: Int, height: Int) -> Matrix<T> {
        Matrix(width: width, height: height, values: values)
    }

    public func with(_ value: T, atY y: Int, x: Int) -> Matrix<T> {
        var result = self
        result[y, x] = value
        return result
    }

    public mutating func scale(row y: Int, by factor: T) {
        assert(factor != 0)
        for x in 0..<width {
            self[y, x] = self[y, x] * factor
        }
    }

    public mutating func add(row y1: Int, toRow y2: Int, scaledBy factor: T) {
        for x in 0..<width {
            self[y2, x] = self[y2, x] + (self[y1, x] * factor)
        }
    }

    public func map<U>(_ f: (T) throws -> U) rethrows -> Matrix<U> where U: IntExpressibleAlgebraicField {
        Matrix<U>(width: width, height: height, values: try values.map(f))
    }

    public func zip<U>(_ rhs: Matrix<T>, with f: (T, T) throws -> U) rethrows -> Matrix<U> where U: IntExpressibleAlgebraicField {
        assert(width == rhs.width && height == rhs.height)
        var zipped = [U](repeating: 0, count: values.count)
        for i in 0..<zipped.count {
            zipped[i] = try f(values[i], rhs.values[i])
        }
        return Matrix<U>(width: width, height: height, values: zipped)
    }

    public mutating func mapInPlace(_ f: (T) throws -> T) rethrows {
        values = try values.map(f)
    }

    public mutating func zipInPlace(_ rhs: Matrix<T>, with f: (T, T) throws -> T) rethrows {
        values = try Swift.zip(values, rhs.values).map(f)
    }

    public static func +(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> { lhs.zip(rhs, with: +) }

    public static func -(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> { lhs.zip(rhs, with: -) }

    public static func *(lhs: Matrix<T>, rhs: T) -> Matrix<T> { lhs.map { $0 * rhs } }

    public static func *(lhs: T, rhs: Matrix<T>) -> Matrix<T> { rhs * lhs }

    public static func /(lhs: Matrix<T>, rhs: T) -> Matrix<T> { lhs.map { $0 / rhs } }

    public static func *(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
        assert(lhs.width == rhs.height)
        var product = Matrix.zero(width: rhs.width, height: lhs.height)
        for y in 0..<lhs.height {
            for x in 0..<rhs.width {
                var cell: T = 0
                for i in 0..<lhs.width {
                    cell = cell + (lhs[y, i] * rhs[i, x])
                }
                product[y, x] = cell
            }
        }
        return product
    }

    public static func +=(lhs: inout Matrix<T>, rhs: Matrix<T>) { lhs.zipInPlace(rhs, with: +) }

    public static func -=(lhs: inout Matrix<T>, rhs: Matrix<T>) { lhs.zipInPlace(rhs, with: -) }

    public static func *=(lhs: inout Matrix<T>, rhs: T) { lhs.mapInPlace { $0 * rhs } }

    public static func /=(lhs: inout Matrix<T>, rhs: T) { lhs.mapInPlace { $0 / rhs } }

    public static func *=(lhs: inout Matrix<T>, rhs: Matrix<T>) {
        assert(lhs.width == rhs.width && lhs.height == rhs.height && lhs.width == lhs.height)
        lhs.values = (lhs * rhs).values
    }

    public struct Row: Sequence {
        private let matrix: Matrix<T>
        public let y: Int
        private var i: Int = 0

        fileprivate init(matrix: Matrix<T>, y: Int) {
            self.matrix = matrix
            self.y = y
        }

        public func makeIterator() -> Iterator { Iterator(row: self) }

        public struct Iterator: IteratorProtocol {
            private let row: Row
            private var i: Int = 0

            fileprivate init(row: Row) {
                self.row = row
            }

            public mutating func next() -> T? {
                guard i < row.matrix.width else { return nil }
                let x = i
                i += 1
                return row.matrix[row.y, x]
            }
        }
    }

    public struct Column: Sequence {
        private let matrix: Matrix<T>
        public let x: Int

        fileprivate init(matrix: Matrix<T>, x: Int) {
            self.matrix = matrix
            self.x = x
        }

        public func makeIterator() -> Iterator { Iterator(column: self) }

        public struct Iterator: IteratorProtocol {
            private let column: Column
            private var i: Int = 0

            fileprivate init(column: Column) {
                self.column = column
            }

            public mutating func next() -> T? {
                guard i < column.matrix.height else { return nil }
                let y = i
                i += 1
                return column.matrix[y, column.x]
            }
        }
    }
}

extension NDArray {
    public var asMatrix: Matrix<T>? {
        dimension == 2 ? Matrix(width: shape[1], height: shape[0], values: values) : nil
    }
}
