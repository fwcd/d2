import D2Graphics
import D2Utils

struct ASTRenderer {
	private let width: Int
	private let height: Int
	private let color: Color
	
	init(width: Int = 300, height: Int = 300, color: Color = Colors.white) {
		self.width = width
		self.height = height
		self.color = color
	}
	
	func render(ast: ExpressionASTNode) throws -> Image {
		// TODO
		fatalError("unimplemented")
	}
}
