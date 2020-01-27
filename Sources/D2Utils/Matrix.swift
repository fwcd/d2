import Foundation

public struct Matrix<T: IntExpressibleAlgebraicField>: Addable, Subtractable, Hashable, CustomStringConvertible {
    public let width: Int
    public let height: Int
    private var values: [T]
    public var description: String {
        (0..<height)
            .map { "(\(self[row: $0].map { "\($0)" }.joined(separator: ", ")))" }
            .joined(separator: "\n")
    }
    
    public init(width: Int, height: Int, values: [T]) {
        assert(values.count == (width * height))
        self.width = width
        self.height = height
        self.values = values
    }
    
    public init(_ values: [[T]]) {
        height = values.count
        width = values.first?.count ?? 0
        self.values = values.flatMap { $0 }
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
            values[(i + 1) * width] = 1
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
    
    public func map<U>(_ f: (T) -> U) -> Matrix<U> where U: IntExpressibleAlgebraicField {
        Matrix<U>(width: width, height: height, values: values.map(f))
    }
    
    public func zip<U>(_ rhs: Matrix<T>, with f: (T, T) -> U) -> Matrix<U> where U: IntExpressibleAlgebraicField {
        assert(width == rhs.width && height == rhs.height)
        var zipped = [U](repeating: 0, count: values.count)
        for i in 0..<zipped.count {
            zipped[i] = f(values[i], rhs.values[i])
        }
        return Matrix<U>(width: width, height: height, values: zipped)
    }
    
    public static func +(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
        lhs.zip(rhs, with: +)
    }

    public static func -(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
        lhs.zip(rhs, with: -)
    }
    
    public static func *(lhs: Matrix<T>, rhs: T) -> Matrix<T> {
        lhs.map { $0 * rhs }
    }
    
    public static func *(lhs: T, rhs: Matrix<T>) -> Matrix<T> {
        rhs * lhs
    }
    
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
                guard i < row.matrix.height else { return nil }
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
                guard i < column.matrix.width else { return nil }
                let y = i
                i += 1
                return column.matrix[y, column.x]
            }
        }
    }
}
