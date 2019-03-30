import D2Utils

public struct LineSegment<T: VecComponent> {
	public let start: Vec2<T>
	public let end: Vec2<T>
	public let color: Color
	
	// TODO: Stroke thickness
	
	public init(from start: Vec2<T>, to end: Vec2<T>, color: Color = Colors.white) {
		self.start = start
		self.end = end
		self.color = color
	}
	
	public init(fromX startX: T, y startY: T, toX endX: T, y endY: T) {
		self.init(from: Vec2(x: startX, y: startY), to: Vec2(x: endX, y: endY))
	}
}
