import D2Utils

public struct ConsoleGraphics: Graphics {
	public func save() {
		print("Saved context")
	}
	
	public func restore() {
		print("Restored context")
	}
	
	public func translate(by offset: Vec2<Double>) {
		print("Translated by \(offset)")
	}
	
	public func rotate(by angle: Double) {
		print("Rotated by \(angle) radians")
	}
	
	public func draw(_ line: LineSegment<Double>) {
		print("Drawed line \(line)")
	}
	
	public func draw(_ rect: Rectangle<Double>) {
		print("Drawed rectangle \(rect)")
	}
	
	public func draw(_ image: Image, at position: Vec2<Double>, withSize size: Vec2<Int>, rotation: Double?) {
		print("Drawed image \(image) at \(position) with size \(size)\(rotation.map { " and rotation \($0)" } ?? "")")
	}
	
	public func draw(_ svg: SVG, at position: Vec2<Double>, withSize size: Vec2<Int>, rotation: Double?) {
		print("Drawed svg \(svg) at \(position) with size \(size)\(rotation.map { " and rotation \($0)" } ?? "")")
	}
	public func draw(_ text: Text) {
		print("Drawed text \(text.value) of size \(text.fontSize) at \(text.position)")
	}
	
	public func draw(_ ellipse: Ellipse<Double>) {
		print("Drawed ellipse \(ellipse)")
	}
}
