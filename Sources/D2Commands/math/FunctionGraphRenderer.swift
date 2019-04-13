import D2Graphics
import D2Utils

struct FunctionGraphRenderer {
	private let width: Int
	private let height: Int
	private let axisArrowSize: Double
	private let axisColor: Color
	private let axisLabelSpacing: Int
	private let pixelToFunctionX: ClosureBijection<Double>
	private let pixelToFunctionY: ClosureBijection<Double>
	
	public init(
		width: Int = 200,
		height: Int = 200,
		scale: Double = 10.0,
		axisArrowSize: Double = 6.0,
		axisLabelSpacing: Int = 45,
		axisColor: Color = Colors.gray
	) {
		self.width = width
		self.height = height
		self.axisArrowSize = axisArrowSize
		self.axisLabelSpacing = axisLabelSpacing
		self.axisColor = axisColor
		
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
		
		// x-axis
		graphics.draw(LineSegment(fromX: 0, y: xAxisY, toX: Double(width), y: xAxisY, color: axisColor))
		graphics.draw(LineSegment(fromX: Double(width), y: xAxisY, toX: Double(width) - axisArrowSize, y: xAxisY - axisArrowSize, color: axisColor))
		graphics.draw(LineSegment(fromX: Double(width), y: xAxisY, toX: Double(width) - axisArrowSize, y: xAxisY + axisArrowSize, color: axisColor))
		
		// y-axis
		graphics.draw(LineSegment(fromX: yAxisX, y: 0, toX: yAxisX, y: Double(height), color: axisColor))
		graphics.draw(LineSegment(fromX: yAxisX, y: 0, toX: yAxisX - axisArrowSize, y: axisArrowSize, color: axisColor))
		graphics.draw(LineSegment(fromX: yAxisX, y: 0, toX: yAxisX + axisArrowSize, y: axisArrowSize, color: axisColor))
		
		let center = Vec2<Int>(x: width, y: height) / 2
		let trimmedHalfSize = (Vec2<Int>(x: width, y: height) / (2 * axisLabelSpacing)) * axisLabelSpacing
		
		// Draw x-axis labels
		for x in stride(from: center.x - trimmedHalfSize.x, through: center.x + trimmedHalfSize.x, by: axisLabelSpacing) {
			let funcX = pixelToFunctionX.apply(Double(x))
			let pos = Vec2(x: Double(x), y: xAxisY + 18)
			graphics.draw(Text(String(format: "%.1f", funcX), withSize: 10, at: pos, color: axisColor))
		}
		
		// Draw y-axis labels
		for y in stride(from: center.y - trimmedHalfSize.y, through: center.y + trimmedHalfSize.y, by: axisLabelSpacing) {
			let funcY = pixelToFunctionY.apply(Double(y))
			let pos = Vec2(x: yAxisX - 30, y: Double(y))
			graphics.draw(Text(String(format: "%.1f", funcY), withSize: 10, at: pos, color: axisColor))
		}
		
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
