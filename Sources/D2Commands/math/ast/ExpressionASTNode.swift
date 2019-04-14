public protocol ExpressionASTNode {
	var occurringVariables: Set<String> { get }
	var label: String { get }
	var childs: [ExpressionASTNode] { get }
	
	func evaluate(with feedDict: [String: Double]) throws -> Double
}

public extension ExpressionASTNode {
	var isConstant: Bool { return occurringVariables.isEmpty }
	var childs: [ExpressionASTNode] { return [] }
	var occurringVariables: Set<String> { return Set(childs.flatMap { $0.occurringVariables }) }
	
	func evaluate() throws -> Double {
		return try evaluate(with: [:])
	}
}
