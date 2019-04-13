public protocol ExpressionASTNode {
	var isConstant: Bool { get }
	
	func evaluate(with feedDict: [String: Double]) throws -> Double
}

public extension ExpressionASTNode {
	func evaluate() throws -> Double {
		return try evaluate(with: [:])
	}
}
