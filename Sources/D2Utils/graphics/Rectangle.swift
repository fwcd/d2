public struct Rectangle<T: VecComponent> {
	public let topLeft: Vec2<T>
	public let size: Vec2<T>
	public let color: Color
	public let isFilled: Bool
	
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
