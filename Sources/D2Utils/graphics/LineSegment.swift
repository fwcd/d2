public struct LineSegment<T: VecComponent> {
	public let start: Vec2<T>
	public let end: Vec2<T>
	public let color: Color
	
	public init(start: Vec2<T>, end: Vec2<T>, color: Color = .white) {
		self.start = start
		self.end = end
		self.color = color
	}
	
	public init(startX: T, startY: T, endX: T, endY: T) {
		self.init(start: Vec2(x: startX, y: startY), end: Vec2(x: endX, y: endY))
	}
}
