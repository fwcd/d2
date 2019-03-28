public struct ImageGraphics: Graphics {
	private(set) var image: Image
	
	public init(image: Image) {
		self.image = image
	}
	
	public mutating func draw(_ line: LineSegment<Int>) {
		var pos = line.start.asDouble
		let end = line.end.asDouble
		let step = (end - pos).normalized
		
		while (pos - end).length > 1 {
			image[pos.floored] = line.color
			pos = pos + step
		}
	}
	
	public mutating func draw(_ rectangle: Rectangle<Int>) {
		// TODO
	}
	
	public mutating func draw(_ image: Image, at position: Vec2<Int>, withSize size: Vec2<Int>) {
		// TODO
	}
}
