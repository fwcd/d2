public protocol Graphics {
	mutating func draw(_ line: LineSegment<Int>)
	
	mutating func draw(_ rectangle: Rectangle<Int>)
	
	mutating func draw(_ img: Image, at position: Vec2<Int>, withSize size: Vec2<Int>)
}

public extension Graphics {
	mutating func draw(_ img: Image) {
		draw(img, at: Vec2(x: 0, y: 0))
	}
	
	mutating func draw(_ img: Image, at position: Vec2<Int>) {
		draw(img, at: position, withSize: img.size)
	}
}
