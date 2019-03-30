import Cairo

public struct CairoGraphics: Graphics {
	private let context: Cairo.Context
	
	init(surface: Surface) {
		context = Cairo.Context(surface: surface)
	}
	
	public init(fromImage image: Image) {
		self.init(surface: image.surface)
	}
	
	public mutating func draw(_ line: LineSegment<Int>) {
		// TODO
	}
	
	public mutating func draw(_ rectangle: Rectangle<Int>) {
		// TODO
	}
	
	public mutating func draw(_ image: Image, at position: Vec2<Int>, withSize size: Vec2<Int>) {
		// TODO
	}
}
