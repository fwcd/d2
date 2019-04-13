import D2Utils

struct DifferenceNode: ExpressionASTNode {
	let lhs: ExpressionASTNode
	let rhs: ExpressionASTNode
	
	func evaluate(with feedDict: [String: Double]) throws -> Double { return (try lhs.evaluate()) - (try rhs.evaluate()) }
}
