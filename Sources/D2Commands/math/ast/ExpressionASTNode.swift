protocol ExpressionASTNode {
	func evaluate(with feedDict: [String: Double]) throws -> Double
}

extension ExpressionASTNode {
	func evaluate() throws -> Double {
		return try evaluate(with: [:])
	}
}
