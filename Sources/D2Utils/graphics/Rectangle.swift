public struct Rectangle<T: VecComponent> {
	public let topLeft: Vec2<T>
	public let size: Vec2<T>
	public let color: Color
	public let isFilled: Bool
	
	public var topRight: Vec2<T> { return topLeft + Vec2(x: size.x, y: 0) }
	public var bottomLeft: Vec2<T> { return topLeft + Vec2(x: 0, y: size.y) }
	public var bottomRight: Vec2<T> { return topLeft + size }
	
	public init(topLeft: Vec2<T>, size: Vec2<T>, color: Color = Colors.white, isFilled: Bool = true) {
		self.topLeft = topLeft
		self.size = size
		self.color = color
		self.isFilled = isFilled
	}
	
	public init(x: T, y: T, width: T, height: T) {
		self.init(topLeft: Vec2(x: x, y: y), size: Vec2(x: x, y: y))
	}
}
