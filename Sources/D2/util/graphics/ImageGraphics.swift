struct ImageGraphics: Graphics {
	private(set) var image: Image
	
	init(image: Image) {
		self.image = image
	}
	
	func draw(_ line: LineSegment<Int>) {
		// TODO
	}
	
	func draw(_ rectangle: Rectangle<Int>) {
		// TODO
	}
	
	func draw(_ image: Image, at position: Vec2<Int>, withSize size: Vec2<Int>) {
		// TODO
	}
}
