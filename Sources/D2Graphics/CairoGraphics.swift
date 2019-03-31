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
	
	public mutating func draw(line: LineSegment<Double>) {
		context.setSource(color: line.color.asDoubleTuple)
		context.move(to: line.start.asTuple)
		context.line(to: line.end.asTuple)
		context.stroke()
	}
	
	public mutating func draw(rect: Rectangle<Double>) {
		context.setSource(color: rect.color.asDoubleTuple)
		context.addRectangle(x: rect.topLeft.x, y: rect.topLeft.y, width: rect.width, height: rect.height)
		
		if rect.isFilled {
			context.fill()
		} else {
			context.stroke()
		}
	}
	
	public mutating func draw(image: Image, at position: Vec2<Double>, withSize size: Vec2<Int>) {
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
	
	public mutating func draw(text: Text) {
		context.setSource(color: text.color.asDoubleTuple)
		context.setFont(size: text.fontSize)
		context.move(to: text.position.asTuple)
		context.show(text: text.value)
	}
}
