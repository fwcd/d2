public struct ConsoleGraphics: Graphics {
	public func draw(_ line: LineSegment<Double>) {
		print("Drawed line \(line)")
	}
	
	public func draw(_ rectangle: Rectangle<Double>) {
		print("Drawed rectangle \(rectangle)")
	}
	
	public func draw(_ image: Image, at position: Vec2<Double>, withSize size: Vec2<Int>) {
		print("Drawed image \(image) at \(position) with size \(size)")
	}
}
