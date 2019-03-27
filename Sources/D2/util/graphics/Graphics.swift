protocol Graphics {
	func draw(_ line: LineSegment<Int>)
	
	func draw(_ rectangle: Rectangle<Int>)
	
	func draw(_ image: Image, at position: Vec2<Int>, withSize size: Vec2<Int>)
}

extension Graphics {
	func draw(_ image: Image) {
		draw(image, at: Vec2(x: 0, y: 0))
	}
	
	func draw(_ image: Image, at position: Vec2<Int>) {
		draw(image, at: position, withSize: image.size)
	}
}
