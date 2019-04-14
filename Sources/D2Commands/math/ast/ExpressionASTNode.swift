public protocol ExpressionASTNode {
	var occurringVariables: Set<String> { get }
	
	func evaluate(with feedDict: [String: Double]) throws -> Double
}

public extension ExpressionASTNode {
	var isConstant: Bool { return occurringVariables.isEmpty }
	
	func evaluate() throws -> Double {
		return try evaluate(with: [:])
	}
}
