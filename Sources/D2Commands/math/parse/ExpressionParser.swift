protocol ExpressionParser {
	func parse(_ input: String) throws -> ExpressionASTNode
}
