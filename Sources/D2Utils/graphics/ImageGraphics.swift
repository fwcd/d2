public struct ImageGraphics: Graphics {
	public private(set) var image: Image
	
	public init(image: Image) {
		self.image = image
	}
	
	public init(width: Int, height: Int) {
		self.init(image: Image(width: width, height: height))
	}
	
	public mutating func draw(_ line: LineSegment<Int>) {
		var pos = line.start.asDouble
		let end = line.end.asDouble
		let step = (end - pos).normalized
		
		while (pos - end).length > 1 {
			let pixelPos = pos.floored
			if image.isInBounds(pixelPos) {
				image[pixelPos] = line.color
			}
			pos = pos + step
		}
		
		if image.isInBounds(line.end) {
			image[line.end] = line.color
		}
	}
	
	public mutating func draw(_ rectangle: Rectangle<Int>) {
		if rectangle.isFilled {
			draw(LineSegment(from: rectangle.topLeft, to: rectangle.topRight, color: rectangle.color))
			draw(LineSegment(from: rectangle.topRight, to: rectangle.bottomRight, color: rectangle.color))
			draw(LineSegment(from: rectangle.topLeft, to: rectangle.bottomLeft, color: rectangle.color))
			draw(LineSegment(from: rectangle.bottomLeft, to: rectangle.bottomRight, color: rectangle.color))
		} else {
			// TODO: Clip rectangle to bounds before iterating
			for pos in rectangle {
				if image.isInBounds(pos) {
					image[pos] = rectangle.color
				}
			}
		}
	}
	
	public mutating func draw(_ drawnImage: Image, at position: Vec2<Int>, withSize size: Vec2<Int>) {
		for y in 0..<size.y {
			for x in 0..<size.x {
				let source = Vec2(x: position.x + x, y: position.y + y)
				let dest = Vec2(x: (x * drawnImage.width) / size.x, y: (y * drawnImage.height) / size.y)
				image[source] = drawnImage[dest].alphaBlend(over: image[source])
			}
		}
	}
}
