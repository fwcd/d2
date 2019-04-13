import D2Utils

struct QuotientNode: ExpressionASTNode {
	let lhs: ExpressionASTNode
	let rhs: ExpressionASTNode
	
	func evaluate(with feedDict: [String: Double]) throws -> Double {
		return (try lhs.evaluate(with: feedDict)) / (try rhs.evaluate(with: feedDict))
	}
}
