struct Vec2<T: Addable & Subtractable>: Addable, Subtractable {
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
}
