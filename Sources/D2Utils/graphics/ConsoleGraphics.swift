public struct ConsoleGraphics: Graphics {
	public func draw(_ line: LineSegment<Int>) {
		print("Drawed line \(line)")
	}
	
	public func draw(_ rectangle: Rectangle<Int>) {
		print("Drawed rectangle \(rectangle)")
	}
	
	public func draw(_ image: Image, at position: Vec2<Int>, withSize size: Vec2<Int>) {
		print("Drawed image \(image) at \(position) with size \(size)")
	}
}
