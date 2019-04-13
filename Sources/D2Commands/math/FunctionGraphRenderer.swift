import D2Graphics
import D2Utils

struct FunctionGraphRenderer {
	private let width = 200
	private let height = 200
	private let scale = 10.0
	
	func render(ast: ExpressionASTNode) throws -> Image {
		let image = try Image(width: width, height: height)
		var graphics = CairoGraphics(fromImage: image)
		var lastPos: Vec2<Double>? = nil
		
		for x in 0..<width {
			let funcX = functionPos(of: Vec2(x: Double(x))).x
			let funcY = try ast.evaluate(with: ["x": funcX])
			let pos = pixelPos(of: Vec2(x: funcX, y: funcY))
			
			if let last = lastPos {
				graphics.draw(LineSegment(from: last, to: pos))
			}
			
			lastPos = pos
		}
		
		return image
	}
	
	private func pixelPos(of functionPos: Vec2<Double>) -> Vec2<Double> {
		return Vec2<Double>(x: (functionPos.x + (Double(width) / (2 * scale))) * scale, y: functionPos.y - Double(height))
	}
	
	private func functionPos(of pixelPos: Vec2<Double>) -> Vec2<Double> {
		return Vec2<Double>(x: (Double(pixelPos.x) / scale) - (Double(width) / (2 * scale)), y: Double(height) + pixelPos.y)
	}
}
