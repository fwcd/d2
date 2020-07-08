public struct Vec2<T: IntExpressibleAlgebraicField>: Addable, Subtractable, Multipliable, Divisible, Negatable, Hashable, CustomStringConvertible {
	public var x: T
	public var y: T

	public var asTuple: (x: T, y: T) { (x: x, y: y) }
	public var asNDArray: NDArray<T> { NDArray([x, y]) }
	public var xInverted: Vec2<T> { Vec2(x: -x, y: y) }
	public var yInverted: Vec2<T> { Vec2(x: x, y: -y) }
	public var description: String { "(\(x), \(y))" }
	
	public init(x: T = 0, y: T = 0) {
		self.x = x
		self.y = y
	}
	
	public init(both value: T) {
		x = value
		y = value
	}
	
	public static func zero() -> Vec2<T> {
		Vec2(x: 0, y: 0)
	}
	
	public static func +(lhs: Vec2<T>, rhs: Vec2<T>) -> Vec2<T> {
		Vec2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}
	
	public static func -(lhs: Vec2<T>, rhs: Vec2<T>) -> Vec2<T> {
		Vec2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}
	
	public static func *(lhs: Vec2<T>, rhs: Vec2<T>) -> Vec2<T> {
		Vec2(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
	}
	
	public static func /(lhs: Vec2<T>, rhs: Vec2<T>) -> Vec2<T> {
		Vec2(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
	}
	
	public static func *(lhs: Vec2<T>, rhs: T) -> Vec2<T> {
		Vec2(x: lhs.x * rhs, y: lhs.y * rhs)
	}
	
	public static func /(lhs: Vec2<T>, rhs: T) -> Vec2<T> {
		Vec2(x: lhs.x / rhs, y: lhs.y / rhs)
	}
	
	public prefix static func -(operand: Vec2<T>) -> Vec2<T> {
		Vec2(x: -operand.x, y: -operand.y)
	}
	
	public func dot(_ other: Vec2<T>) -> T {
		(x * other.x) + (y * other.y)
	}
	
	public func cross(_ other: Vec2<T>) -> T {
		(x * other.y) - (y * other.x)
	}
	
	public func map<R: IntExpressibleAlgebraicField>(mapper: (T) -> R) -> Vec2<R> {
		Vec2<R>(x: mapper(x), y: mapper(y))
	}
	
	public func with(x newX: T) -> Vec2<T> {
		Vec2(x: newX, y: y)
	}
	
	public func with(y newY: T) -> Vec2<T> {
		Vec2(x: x, y: newY)
	}
}

extension Vec2 where T: BinaryFloatingPoint {
	public var squaredMagnitude: T { ((x * x) + (y * y)) }
	public var magnitude: T { squaredMagnitude.squareRoot() }
	public var normalized: Vec2<T> { self / magnitude }
	public var floored: Vec2<Int> { Vec2<Int>(x: Int(x.rounded(.down)), y: Int(y.rounded(.down))) }
}

extension Vec2 where T: BinaryInteger {
	public var squaredMagnitude: Double { Double((x * x) + (y * y)) }
	public var magnitude: Double { squaredMagnitude.squareRoot() }
	public var asDouble: Vec2<Double> { map { Double($0) } }
}

extension NDArray {
    public var asVec2: Vec2<T>? {
        shape == [2] ? Vec2(x: values[0], y: values[1]) : nil
    }
}
