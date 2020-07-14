public struct Vector<T: IntExpressibleAlgebraicField>: Addable, Subtractable, Multipliable, Divisible, Negatable, Hashable, CustomStringConvertible {
	public var values: [T]

	public var asNDArray: NDArray<T> { NDArray(values) }
	public var description: String { "(\(values.map { "\($0)" }.joined(separator: ", ")))" }
	
	public init(_ values: [T]) {
		self.values = values
	}
	
	public static func zero(size: Int) -> Self {
		Vector(Array(repeating: 0, count: size))
	}

    public subscript(_ i: Int) -> T {
        get { values[i] }
        set { values[i] = newValue }
    }

    public func map<U>(_ transform: (T) throws -> U) rethrows -> Vector<U> where U: IntExpressibleAlgebraicField {
        Vector<U>(try values.map(transform))
    }

    public func zip<U, R>(_ rhs: Vector<U>, _ zipper: (T, U) throws -> R) rethrows -> Vector<R> where U: IntExpressibleAlgebraicField, R: IntExpressibleAlgebraicField {
        Vector<R>(try Swift.zip(values, rhs.values).map(zipper))
    }

	public mutating func mapInPlace(_ transform: (T) throws -> T) rethrows {
        values = try values.map(transform)
    }

	public mutating func zipInPlace<U>(_ rhs: Vector<U>, _ zipper: (T, U) throws -> T) rethrows where U: IntExpressibleAlgebraicField {
        values = try Swift.zip(values, rhs.values).map(zipper)
    }
	
	public static func +(lhs: Self, rhs: Self) -> Self { lhs.zip(rhs, +) }
	
	public static func -(lhs: Self, rhs: Self) -> Self { lhs.zip(rhs, -) }
	
	public static func *(lhs: Self, rhs: Self) -> Self { lhs.zip(rhs, *) }
	
	public static func /(lhs: Self, rhs: Self) -> Self { lhs.zip(rhs, /) }
	
	public static func *(lhs: Self, rhs: T) -> Self { lhs.map { $0 * rhs } }
	
	public static func /(lhs: Self, rhs: T) -> Self { lhs.map { $0 / rhs } }
		
	public static func *(lhs: T, rhs: Self) -> Self { rhs.map { lhs * $0 } }
	
	public static func /(lhs: T, rhs: Self) -> Self { rhs.map { lhs / $0 } }
	
	public prefix static func -(operand: Self) -> Self { operand.map { -$0 } }

	public static func +=(lhs: inout Self, rhs: Self) { lhs.zipInPlace(rhs, +) }

	public static func -=(lhs: inout Self, rhs: Self) { lhs.zipInPlace(rhs, -) }

	public static func *=(lhs: inout Self, rhs: Self) { lhs.zipInPlace(rhs, *) }

	public static func /=(lhs: inout Self, rhs: Self) { lhs.zipInPlace(rhs, /) }

	public mutating func negate() { mapInPlace { -$0 } }
	
	public func dot(_ other: Self) -> T {
		(self * other).values.reduce(0, +)
	}

	public func projected(onto other: Self) -> Vector<T> {
		let factor: T = dot(other) / other.dot(other)
		return factor * other
	}
}

extension Vector where T: BinaryFloatingPoint {
	public var magnitude: T { dot(self).squareRoot() }
	public var normalized: Self { self / magnitude }
	public var floored: Vector<Int> { map { Int($0.rounded(.down)) } }
}

extension Vector where T: BinaryInteger {
	public var magnitude: Double { Double(dot(self)).squareRoot() }
	public var asDouble: Vector<Double> { map { Double($0) } }
}

extension Vector where T == Rational {
    public var magnitude: Double { dot(self).asDouble.squareRoot() }
    public var asDouble: Vector<Double> { map { $0.asDouble } }
}

extension NDArray {
    public var asVector: Vector<T>? {
        dimension == 1 ? Vector(values) : nil
    }
}
