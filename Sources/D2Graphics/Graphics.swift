import D2Utils

public protocol Graphics {
	mutating func draw(line: LineSegment<Double>)
	
	mutating func draw(rect: Rectangle<Double>)
	
	mutating func draw(image: Image, at position: Vec2<Double>, withSize size: Vec2<Int>)
	
	mutating func draw(text: Text)
}

public extension Graphics {
	mutating func draw(image: Image) {
		draw(image: image, at: Vec2(x: 0, y: 0))
	}
	
	mutating func draw(image: Image, at position: Vec2<Double>) {
		draw(image: image, at: position, withSize: image.size)
	}
}
