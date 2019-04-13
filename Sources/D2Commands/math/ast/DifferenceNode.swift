import D2Utils

struct DifferenceNode: ExpressionASTNode {
	let lhs: ExpressionASTNode
	let rhs: ExpressionASTNode
	var isConstant: Bool { return lhs.isConstant && rhs.isConstant }
	
	func evaluate(with feedDict: [String: Double]) throws -> Double {
		return (try lhs.evaluate(with: feedDict)) - (try rhs.evaluate(with: feedDict))
	}
}
