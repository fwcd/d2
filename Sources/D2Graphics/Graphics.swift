import D2Utils

public protocol Graphics {
	mutating func draw(_ line: LineSegment<Double>)
	
	mutating func draw(_ rectangle: Rectangle<Double>)
	
	mutating func draw(_ image: Image, at position: Vec2<Double>, withSize size: Vec2<Int>)
}

public extension Graphics {
	mutating func draw(_ img: Image) {
		draw(img, at: Vec2(x: 0, y: 0))
	}
	
	mutating func draw(_ image: Image, at position: Vec2<Double>) {
		draw(image, at: position, withSize: image.size)
	}
}
