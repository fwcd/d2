import D2Utils

public struct ConsoleGraphics: Graphics {
	public func draw(line: LineSegment<Double>) {
		print("Drawed line \(line)")
	}
	
	public func draw(rect: Rectangle<Double>) {
		print("Drawed rectangle \(rect)")
	}
	
	public func draw(image: Image, at position: Vec2<Double>, withSize size: Vec2<Int>) {
		print("Drawed image \(image) at \(position) with size \(size)")
	}
	
	public func draw(text: Text) {
		print("Drawed text \(text.value) of size \(text.fontSize) at \(text.position)")
	}
}
