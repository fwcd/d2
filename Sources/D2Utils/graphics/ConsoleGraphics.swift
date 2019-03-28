struct ConsoleGraphics: Graphics {
	func draw(_ line: LineSegment<Int>) {
		print("Drawed line \(line)")
	}
	
	func draw(_ rectangle: Rectangle<Int>) {
		print("Drawed rectangle \(rectangle)")
	}
	
	func draw(_ image: Image, at position: Vec2<Int>, withSize size: Vec2<Int>) {
		print("Drawed image \(image) at \(position) with size \(size)")
	}
}
