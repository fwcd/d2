import D2Graphics
import D2Utils

struct FunctionGraphRenderer {
	private let width: Int
	private let height: Int
	private let pixelToFunctionX: ClosureBijection<Double>
	private let pixelToFunctionY: ClosureBijection<Double>
	
	public init(width: Int = 200, height: Int = 200, scale: Double = 10.0) {
		self.width = width
		self.height = height
		
		pixelToFunctionX = Scaling(by: 1.0 / scale).then(Translation(by: -Double(width) / (2 * scale)))
		pixelToFunctionY = Scaling(by: -1.0).then(Translation(by: Double(height / 2)))
	}
	
	func render(ast: ExpressionASTNode) throws -> Image {
		let image = try Image(width: width, height: height)
		var graphics = CairoGraphics(fromImage: image)
		var lastPos: Vec2<Double>? = nil
		
		// Draw axes
		let xAxisY = pixelToFunctionY.inverseApply(0)
		let yAxisX = pixelToFunctionX.inverseApply(0)
		
		graphics.draw(LineSegment(fromX: 0, y: xAxisY, toX: Double(width), y: xAxisY, color: Colors.gray))
		graphics.draw(LineSegment(fromX: yAxisX, y: 0, toX: yAxisX, y: Double(height), color: Colors.gray))
		
		// Draw graph of function
		for x in 0..<width {
			let funcX = pixelToFunctionX.apply(Double(x))
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
		return Vec2(x: pixelToFunctionX.inverseApply(functionPos.x), y: pixelToFunctionY.inverseApply(functionPos.y))
	}
	
	private func functionPos(of pixelPos: Vec2<Double>) -> Vec2<Double> {
		return Vec2(x: pixelToFunctionX.apply(pixelPos.x), y: pixelToFunctionY.apply(pixelPos.y))
	}
}
