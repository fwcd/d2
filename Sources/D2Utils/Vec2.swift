public struct Vec2<T: IntExpressibleAlgebraicField>: Addable, Subtractable, Multipliable, Divisible, Negatable, Hashable, CustomStringConvertible {
	public var x: T
	public var y: T
	public var asTuple: (x: T, y: T) { (x: x, y: y) }
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
	
	public func dot(other: Vec2<T>) -> T {
		(x * other.x) + (y * other.y)
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
	public var magnitude: T { return ((x * x) + (y * y)).squareRoot() }
	public var normalized: Vec2<T> { return self / magnitude }
	public var floored: Vec2<Int> { return Vec2<Int>(x: Int(x.rounded(.down)), y: Int(y.rounded(.down))) }
}

extension Vec2 where T: BinaryInteger {
	public var magnitude: Double { return Double((x * x) + (y * y)).squareRoot() }
	public var asDouble: Vec2<Double> { return map { Double($0) } }
}
