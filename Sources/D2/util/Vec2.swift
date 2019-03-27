struct Vec2<T: Addable & Subtractable & Multipliable & Divisible>: Addable, Subtractable {
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
}

extension Vec2 where T: FloatingPoint {
	var length: T { return ((x * x) + (y * y)).squareRoot() }
}
