import D2Utils

struct SumNode: ExpressionASTNode {
	let lhs: ExpressionASTNode
	let rhs: ExpressionASTNode
	
	func evaluate(with feedDict: [String: Double]) throws -> Double { return (try lhs.evaluate()) + (try rhs.evaluate()) }
}
