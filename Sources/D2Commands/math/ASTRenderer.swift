import D2Graphics
import D2Utils

struct ASTRenderer {
	private let width: Int
	private let height: Int
	private let padding: Double
	private let color: Color
	
	init(
		width: Int = 300,
		height: Int = 300,
		padding: Double = 10.0,
		color: Color = Colors.white
	) {
		self.width = width
		self.height = height
		self.padding = padding
		self.color = color
	}
	
	func render(ast: ExpressionASTNode) throws -> Image {
		let image = try Image(width: width, height: height)
		var graphics: Graphics = CairoGraphics(fromImage: image)
		
		try render(ast, to: &graphics, at: Vec2(x: Double(width / 2), y: padding))
		
		return image
	}
	
	private func render(_ node: ExpressionASTNode, to graphics: inout Graphics, at position: Vec2<Double>) throws {
		graphics.draw(Text(node.label, at: position))
	}
}
