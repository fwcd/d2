public protocol Graphics {
	mutating func draw(_ line: LineSegment<Int>)
	
	mutating func draw(_ rectangle: Rectangle<Int>)
	
	mutating func draw(_ image: Image, at position: Vec2<Int>, withSize size: Vec2<Int>)
}

extension Graphics {
	mutating func draw(_ image: Image) {
		draw(image, at: Vec2(x: 0, y: 0))
	}
	
	mutating func draw(_ image: Image, at position: Vec2<Int>) {
		draw(image, at: position, withSize: image.size)
	}
}
