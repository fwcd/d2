protocol Graphics {
	func draw(_ line: LineSegment<Int>)
	
	func draw(_ rectangle: Rectangle<Int>)
	
	func draw(_ image: Image, position: Vec2<Int>, size: Vec2<Int>)
}

extension Graphics {
	func draw(_ image: Image) {
		draw(image, position: Vec2(x: 0, y: 0))
	}
	
	func draw(_ image: Image, position: Vec2<Int>) {
		draw(image, position: position, size: image.size)
	}
}
