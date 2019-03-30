import Cairo

public struct CairoGraphics: Graphics {
	private let context: Cairo.Context
	
	init(surface: Surface) {
		context = Cairo.Context(surface: surface)
	}
	
	public init(fromImage image: Image) {
		self.init(surface: image.surface)
	}
	
	public mutating func draw(_ line: LineSegment<Double>) {
		context.move(to: line.start.asTuple)
		context.line(to: line.end.asTuple)
		context.stroke()
	}
	
	public mutating func draw(_ rectangle: Rectangle<Double>) {
		context.addRectangle(x: rectangle.topLeft.x, y: rectangle.topLeft.y, width: rectangle.width, height: rectangle.height)
		if rectangle.isFilled {
			context.fill()
		} else {
			context.stroke()
		}
	}
	
	public mutating func draw(_ image: Image, at position: Vec2<Double>, withSize size: Vec2<Int>) {
		// TODO
	}
}
