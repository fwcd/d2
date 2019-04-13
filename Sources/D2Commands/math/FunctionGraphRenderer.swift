import D2Graphics
import D2Utils

struct FunctionGraphRenderer {
	func render(ast: ExpressionASTNode) throws -> Image {
		let width = 200
		let height = 200
		let scale = 10.0
		let image = try Image(width: width, height: height)
		var graphics = CairoGraphics(fromImage: image)
		var lastPos: Vec2<Double>? = nil
		
		for x in 0..<width {
			let funcX = (Double(x) / scale) - (Double(width) / (2 * scale))
			let funcY = try ast.evaluate(with: ["x": funcX])
			let pos = Vec2(x: Double(x), y: Double(height) - funcY)
			
			if let last = lastPos {
				graphics.draw(LineSegment(from: last, to: pos))
			}
			
			lastPos = pos
		}
		
		return image
	}
}
