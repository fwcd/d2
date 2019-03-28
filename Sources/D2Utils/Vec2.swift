typealias VecComponent = Addable & Subtractable & Multipliable & Divisible

struct Vec2<T: VecComponent>: Addable, Subtractable {
	let x: T
	let y: T
	
	init(x: T, y: T) {
		self.x = x
		self.y = y
	}
	
	static func +(lhs: Vec2<T>, rhs: Vec2<T>) -> Vec2<T> {
		return Vec2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}
	
	static func -(lhs: Vec2<T>, rhs: Vec2<T>) -> Vec2<T> {
		return Vec2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}
	
	static func *(lhs: Vec2<T>, rhs: T) -> Vec2<T> {
		return Vec2(x: lhs.x * rhs, y: lhs.y * rhs)
	}
	
	static func /(lhs: Vec2<T>, rhs: T) -> Vec2<T> {
		return Vec2(x: lhs.x / rhs, y: lhs.y / rhs)
	}
	
	func dot(other: Vec2<T>) -> T {
		return (x * other.x) + (y * other.y)
	}
	
	func map<R: VecComponent>(mapper: (T) -> R) -> Vec2<R> {
		return Vec2<R>(x: mapper(x), y: mapper(y))
	}
}

extension Vec2 where T: BinaryFloatingPoint {
	var length: T { return ((x * x) + (y * y)).squareRoot() }
	var normalized: Vec2<T> { return self / length }
	var floored: Vec2<Int> { return Vec2<Int>(x: Int(x.rounded(.down)), y: Int(y.rounded(.down))) }
}

extension Vec2 where T: BinaryInteger {
	var asDouble: Vec2<Double> { return map { Double($0) } }
}
