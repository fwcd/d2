public struct ImageGraphics: Graphics {
	public private(set) var image: Image
	
	public init(image: Image) {
		self.image = image
	}
	
	public init(width: Int, height: Int) {
		self.init(image: Image(width: width, height: height))
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
		if rectangle.isFilled {
			draw(LineSegment(from: rectangle.topLeft, to: rectangle.topRight))
			draw(LineSegment(from: rectangle.topRight, to: rectangle.bottomRight))
			draw(LineSegment(from: rectangle.topLeft, to: rectangle.bottomLeft))
			draw(LineSegment(from: rectangle.bottomLeft, to: rectangle.bottomRight))
		} else {
			for pos in rectangle {
				image[pos] = rectangle.color
			}
		}
	}
	
	public mutating func draw(_ image: Image, at position: Vec2<Int>, withSize size: Vec2<Int>) {
		// TODO
	}
}
