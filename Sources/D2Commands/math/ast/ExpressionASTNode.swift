public protocol ExpressionASTNode {
	func evaluate(with feedDict: [String: Double]) throws -> Double
}

public extension ExpressionASTNode {
	func evaluate() throws -> Double {
		return try evaluate(with: [:])
	}
}
