protocol ExpressionParser {
	func parse(_ str: String) throws -> ExpressionASTNode
}
