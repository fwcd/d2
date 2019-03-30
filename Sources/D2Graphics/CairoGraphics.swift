import Cairo
import D2Utils

public struct CairoGraphics: Graphics {
	private let context: Cairo.Context
	
	init(surface: Surface) {
		context = Cairo.Context(surface: surface)
	}
	
	public init(fromImage image: Image) {
		self.init(surface: image.surface)
	}
	
	public mutating func draw(_ line: LineSegment<Double>) {
		context.setSource(color: line.color.asDoubleTuple)
		context.move(to: line.start.asTuple)
		context.line(to: line.end.asTuple)
		context.stroke()
	}
	
	public mutating func draw(_ rectangle: Rectangle<Double>) {
		context.setSource(color: rectangle.color.asDoubleTuple)
		context.addRectangle(x: rectangle.topLeft.x, y: rectangle.topLeft.y, width: rectangle.width, height: rectangle.height)
		
		if rectangle.isFilled {
			context.fill()
		} else {
			context.stroke()
		}
	}
	
	public mutating func draw(_ image: Image, at position: Vec2<Double>, withSize size: Vec2<Int>) {
		let originalWidth = image.width
		let originalHeight = image.height
		
		context.save()
		
		let scaleFactor = Vec2(x: Double(size.x) / Double(originalWidth), y: Double(size.y) / Double(originalHeight))
		
		if originalWidth != size.x || originalHeight != size.y {
			context.scale(x: scaleFactor.x, y: scaleFactor.y)
		}
		
		context.translate(x: position.x / scaleFactor.x, y: position.y / scaleFactor.y)
		context.source = Pattern(surface: image.surface)
		context.paint()
		context.restore()
	}
}
